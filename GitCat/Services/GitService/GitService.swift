//
//  GitService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import Foundation
import OSLog

// MARK: - GitRefreshStep -

/// Parts of a full refresh, in the order they run. Opening a repository reports progress after each one.
enum GitRefreshStep: CaseIterable {
    case status
    case upstream
    case branches
    case history

    var title: String {
        switch self {
        case .status: "Reading status"
        case .upstream: "Comparing with origin"
        case .branches: "Loading branches"
        case .history: "Reading history"
        }
    }
}

// MARK: - GitError -

/// A git command that failed, with git's own explanation.
struct GitError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

// MARK: - GitService -
class GitService {
    // MARK: - Public properties -
    //
    // Values are delivered on the main thread, whichever thread refreshed them.

    /// `nil` on a detached HEAD.
    var currentBranch: AnyPublisher<String?, Never> {
        currentBranchSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    /// Local branches.
    var branches: AnyPublisher<[String], Never> {
        branchesSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var remotes: AnyPublisher<[String], Never> {
        remotesSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var changedFiles: AnyPublisher<[ChangedFile], Never> {
        changedFilesSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    /// `nil` when the current branch doesn't track a remote branch.
    var upstream: AnyPublisher<UpstreamStatus?, Never> {
        upstreamSubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    var history: AnyPublisher<HistorySummary, Never> {
        historySubject.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

    // MARK: - Private properties -

    /// Untracked files above this count are listed without line counts, since each one needs its own git call.
    private static let maximumCountedUntrackedFiles = 200
    private let shellService: ShellService
    private let currentBranchSubject: CurrentValueSubject<String?, Never> = .init(nil)
    private let branchesSubject: CurrentValueSubject<[String], Never> = .init([])
    private let remotesSubject: CurrentValueSubject<[String], Never> = .init([])
    private let changedFilesSubject: CurrentValueSubject<[ChangedFile], Never> = .init([])
    private let upstreamSubject: CurrentValueSubject<UpstreamStatus?, Never> = .init(nil)
    private let historySubject: CurrentValueSubject<HistorySummary, Never> = .init(.init(commitCount: 0, lastCommit: nil))

    // MARK: - Initializer -

    init(shellService: ShellService) {
        self.shellService = shellService
    }
}

// MARK: - Public methods -

extension GitService {
    /// Refreshes everything on the calling thread, so callers on the main thread should move it off it.
    /// Steps that fail keep their previously published values.
    func refreshChangedFiles() {
        GitRefreshStep.allCases.forEach { step in
            do {
                publish(try load(step))
            } catch {
                Logger.git.error("\(step.title, privacy: .public) failed: \(error.localizedDescription)")
            }
        }
    }

    /// Runs the step's git commands on a background thread, then publishes the result on the main thread.
    /// Throws `GitError` when git fails, e.g. because the directory is no longer a repository.
    @MainActor func refresh(_ step: GitRefreshStep) async throws {
        let result = try await Task.detached(priority: .userInitiated) { [self] in try load(step) }.value
        publish(result)
    }

    /// Changes of the file on its side of the index. Empty for binary files.
    @MainActor func diff(for file: ChangedFile) async throws -> [DiffLine] {
        let command = diffCommand(for: file)
        let isUntracked = file.status == .untracked
        return try await Task.detached(priority: .userInitiated) { [self] in
            // Comparing with /dev/null always "fails", since the files differ.
            let output = isUntracked ? shellService.execute(command) : try run(command)
            return parseDiff(output)
        }.value
    }

    @MainActor func stage(_ files: [ChangedFile]) async throws {
        guard !files.isEmpty else { return }
        try await performAndRefresh(["\(GitCommands.add.rawValue) \(quotedPaths(of: files))"])
    }

    @MainActor func unstage(_ files: [ChangedFile]) async throws {
        guard !files.isEmpty else { return }
        // There is no HEAD to restore the index from before the first commit.
        let command: GitCommands = historySubject.value.lastCommit == nil ? .removeFromIndex : .unstage
        try await performAndRefresh(["\(command.rawValue) \(quotedPaths(of: files))"])
    }

    /// Throws away the file's changes on its side of the index. Can't be undone.
    @MainActor func discard(_ file: ChangedFile) async throws {
        try await performAndRefresh(discardCommands(for: file))
    }

    @MainActor func commit(summary: String, description: String) async throws {
        var command = "\(GitCommands.commit.rawValue) -m \(summary.shellQuoted)"
        if !description.isEmpty {
            command += " -m \(description.shellQuoted)"
        }
        try await performAndRefresh([command])
    }

    @MainActor func fetch() async throws {
        try await performAndRefresh([GitCommands.fetch.rawValue])
    }

    @MainActor func pull() async throws {
        try await performAndRefresh([GitCommands.pull.rawValue])
    }

    /// Pushes to the upstream. A branch without one gets published to `origin`, or the only remote there is.
    @MainActor func push() async throws {
        if upstreamSubject.value != nil {
            try await performAndRefresh([GitCommands.push.rawValue])
            return
        }

        let remotes = remotesSubject.value
        guard let remote = remotes.contains("origin") ? "origin" : remotes.first else {
            throw GitError(message: "This repository has no remote to push to.")
        }
        try await performAndRefresh(["\(GitCommands.push.rawValue) -u \(remote.shellQuoted) HEAD"])
    }
}

// MARK: - Private methods -

private extension GitService {
    enum RefreshResult {
        case changedFiles([ChangedFile])
        case upstream(UpstreamStatus?)
        case branches(current: String?, local: [String], remotes: [String])
        case history(HistorySummary)
    }

    /// Only runs commands and parses their output, so it is safe to call from any thread.
    func load(_ step: GitRefreshStep) throws -> RefreshResult {
        switch step {
        case .status:
            return .changedFiles(try loadChangedFiles())
        case .upstream:
            return .upstream(loadUpstream())
        case .branches:
            // Fails on a detached HEAD.
            let current = shellService.execute(GitCommands.branchName.rawValue).trimmingCharacters(in: .whitespacesAndNewlines)
            return .branches(current: current.isEmpty ? nil : current,
                             local: lines(of: try run(GitCommands.localBranches.rawValue)),
                             remotes: lines(of: try run(GitCommands.remotes.rawValue)))
        case .history:
            return .history(loadHistory())
        }
    }

    /// Output of a git command that has to succeed.
    func run(_ command: String) throws -> String {
        let result = shellService.run(command)
        guard result.succeeded else {
            let message = result.errorOutput.trimmingCharacters(in: .whitespacesAndNewlines)
            throw GitError(message: message.isEmpty ? "\(command) failed" : message)
        }
        return result.output
    }

    /// Runs the commands one after another on a background thread, stopping at the first one that fails. Everything
    /// is refreshed either way, since a failed command may still have changed something.
    @MainActor func performAndRefresh(_ commands: [String]) async throws {
        let result = await Task.detached(priority: .userInitiated) { [self] in
            let result = Result { try commands.forEach { _ = try run($0) } }
            refreshChangedFiles()
            return result
        }.value

        if case .failure(let error) = result {
            Logger.git.error("\(commands.joined(separator: "; ")) failed: \(error.localizedDescription)")
            throw error
        }
    }

    func publish(_ result: RefreshResult) {
        switch result {
        case .changedFiles(let files):
            changedFilesSubject.send(files)
        case .upstream(let upstream):
            upstreamSubject.send(upstream)
        case .branches(let current, let local, let remotes):
            currentBranchSubject.send(current)
            branchesSubject.send(local)
            remotesSubject.send(remotes)
        case .history(let history):
            historySubject.send(history)
        }
    }

    func lines(of output: String) -> [String] {
        output.split(separator: "\n").map(String.init)
    }

    func quotedPaths(of files: [ChangedFile]) -> String {
        files.flatMap { [$0.originalPath, $0.path].compactMap { $0 } }
            .map(\.shellQuoted)
            .joined(separator: " ")
    }
}

// MARK: - Loading -

private extension GitService {
    func loadChangedFiles() throws -> [ChangedFile] {
        let files = parseStatus(try run(GitCommands.status.rawValue))
        let unstagedCounts = parseNumstat(try run(GitCommands.numstat.rawValue))
        let stagedCounts = parseNumstat(try run("\(GitCommands.numstat.rawValue) --staged"))
        var countedUntrackedFiles = 0

        return files.map { file in
            var file = file
            let counts: LineCounts?
            if file.status == .untracked {
                guard countedUntrackedFiles < Self.maximumCountedUntrackedFiles else { return file }
                countedUntrackedFiles += 1
                counts = lineCounts(ofUntracked: file.path)
            } else {
                counts = file.isStaged ? stagedCounts[file.path] : unstagedCounts[file.path]
            }
            file.additions = counts?.additions
            file.deletions = counts?.deletions
            return file
        }
    }

    func lineCounts(ofUntracked path: String) -> LineCounts? {
        let output = shellService.execute("\(GitCommands.diffUntracked.rawValue) --numstat -- /dev/null \(path.shellQuoted)")
        return parseNumstat(output).values.first
    }

    /// `nil` when there is no upstream (e.g. no remote, or a branch that was never pushed).
    func loadUpstream() -> UpstreamStatus? {
        let nameResult = shellService.run(GitCommands.upstreamName.rawValue)
        let name = nameResult.output.trimmingCharacters(in: .whitespacesAndNewlines)
        guard nameResult.succeeded, !name.isEmpty else { return nil }

        let comparison = shellService.run(GitCommands.upstreamComparison.rawValue)
        let counts = comparison.output.split(whereSeparator: \.isWhitespace).compactMap { Int($0) }
        guard comparison.succeeded, counts.count == 2 else { return UpstreamStatus(name: name, ahead: 0, behind: 0) }

        return UpstreamStatus(name: name, ahead: counts[0], behind: counts[1])
    }

    /// Both commands fail before the first commit, which simply means there is no history yet.
    func loadHistory() -> HistorySummary {
        let count = Int(shellService.execute(GitCommands.commitCount.rawValue)
            .trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0

        let columns = shellService.execute(GitCommands.lastCommit.rawValue)
            .trimmingCharacters(in: .newlines)
            .split(separator: "\t", maxSplits: 1, omittingEmptySubsequences: false)
        let lastCommit = columns.count == 2 ? CommitSummary(hash: String(columns[0]), message: String(columns[1])) : nil

        return HistorySummary(commitCount: count, lastCommit: lastCommit)
    }

    func diffCommand(for file: ChangedFile) -> String {
        if file.status == .untracked {
            return "\(GitCommands.diffUntracked.rawValue) -- /dev/null \(file.path.shellQuoted)"
        }
        // Passing both names of a renamed file shows it as a rename instead of a new file.
        return "\(GitCommands.diff.rawValue)\(file.isStaged ? " --staged" : "") -- \(quotedPaths(of: [file]))"
    }

    func discardCommands(for file: ChangedFile) -> [String] {
        let path = file.path.shellQuoted
        guard file.isStaged else {
            let command: GitCommands = file.status == .untracked ? .cleanUntracked : .discardUnstaged
            return ["\(command.rawValue) \(path)"]
        }

        switch file.status {
        case .new, .copied:
            return ["\(GitCommands.removeAdded.rawValue) \(path)"]
        case .renamed:
            // The new name isn't in HEAD, so it's removed, and the old one is brought back.
            return ["\(GitCommands.removeAdded.rawValue) \(path)"]
                + (file.originalPath.map { ["\(GitCommands.discardStaged.rawValue) \($0.shellQuoted)"] } ?? [])
        default:
            return ["\(GitCommands.discardStaged.rawValue) \(path)"]
        }
    }
}

// MARK: - Parsing git status output -

private extension GitService {
    // Example output (entries separated by NUL, shown here on separate lines):
    // M  GitCat/Models/File.swift
    //  M GitCat/Services/GitService.swift
    // R  GitCat/Models/ChangedFile.swift
    // GitCat/Models/OldName.swift
    // ?? GitCat/Models/DiffLine.swift
    //
    // The first column is the index (staged) status, the second the working tree (unstaged) status. Renames and copies
    // are followed by an extra entry with the original path.
    func parseStatus(_ output: String) -> [ChangedFile] {
        var entries = output.split(separator: "\0")[...]
        var files: [ChangedFile] = []

        while let entry = entries.popFirst() {
            let characters = Array(entry.prefix(2))
            guard entry.count > 3,
                  let indexStatus = FileStatus(rawValue: String(characters[0])),
                  let workingTreeStatus = FileStatus(rawValue: String(characters[1])) else { continue }

            let path = String(entry.dropFirst(3))
            let originalPath = [FileStatus.renamed, .copied].contains(indexStatus) ? entries.popFirst().map(String.init) : nil

            // Conflicts are "UU", "AU", "DU", "UA", "UD", "AA" or "DD", and can only be resolved in the working tree.
            let isUnmerged = indexStatus == .unmerged || workingTreeStatus == .unmerged
                || (indexStatus == workingTreeStatus && [FileStatus.new, .deleted].contains(indexStatus))
            if isUnmerged {
                files.append(ChangedFile(path: path, status: .unmerged, isStaged: false))
                continue
            }
            if indexStatus == .untracked {
                files.append(ChangedFile(path: path, status: .untracked, isStaged: false))
                continue
            }
            if indexStatus != .unmodified {
                files.append(ChangedFile(path: path, status: indexStatus, isStaged: true, originalPath: originalPath))
            }
            if workingTreeStatus != .unmodified {
                files.append(ChangedFile(path: path, status: workingTreeStatus, isStaged: false))
            }
        }

        return files
    }
}

// MARK: - Parsing git diff --numstat output -

private extension GitService {
    struct LineCounts {
        let additions: Int?
        let deletions: Int?
    }

    // Example output (entries separated by NUL):
    // 4    2    GitCat/Models/File.swift
    // -    -    GitCat/Assets.xcassets/icon.png
    //
    // Binary files have "-" instead of line counts.
    func parseNumstat(_ output: String) -> [String: LineCounts] {
        var counts: [String: LineCounts] = [:]
        output.split(separator: "\0").forEach { entry in
            let columns = entry.split(separator: "\t", maxSplits: 2, omittingEmptySubsequences: false)
            guard columns.count == 3 else { return }
            counts[String(columns[2]).trimmingCharacters(in: .newlines)] = LineCounts(additions: Int(columns[0]),
                                                                                      deletions: Int(columns[1]))
        }
        return counts
    }
}

// MARK: - Parsing git diff output -

private extension GitService {
    // Example output:
    // diff --git a/GitCat/Models/File.swift b/GitCat/Models/File.swift
    // index 3b18e51..a9c1f1e 100644
    // --- a/GitCat/Models/File.swift
    // +++ b/GitCat/Models/File.swift
    // @@ -14,9 +14,13 @@ struct File {
    //      let path: String
    // -    let status: String
    // +    let status: FileStatus
    //
    // Everything before the first hunk is skipped. Binary files have no hunks at all.
    func parseDiff(_ output: String) -> [DiffLine] {
        var diffLines: [DiffLine] = []
        var oldNumber = 0
        var newNumber = 0
        var isInHunk = false

        for line in output.split(separator: "\n", omittingEmptySubsequences: false) {
            if line.hasPrefix("@@") {
                let ranges = line.split(separator: " ")
                oldNumber = ranges.count > 1 ? startLine(of: ranges[1]) : 0
                newNumber = ranges.count > 2 ? startLine(of: ranges[2]) : 0
                isInHunk = true
                diffLines.append(DiffLine(id: diffLines.count, kind: .hunk, text: String(line),
                                          oldNumber: nil, newNumber: nil))
                continue
            }
            // Header of the next file, only shown when both names of a rename were asked for.
            if line.hasPrefix("diff --git") {
                isInHunk = false
                continue
            }
            guard isInHunk, let marker = line.first else { continue }

            let text = String(line.dropFirst())
            switch marker {
            case "+":
                diffLines.append(DiffLine(id: diffLines.count, kind: .added, text: text,
                                          oldNumber: nil, newNumber: newNumber))
                newNumber += 1
            case "-":
                diffLines.append(DiffLine(id: diffLines.count, kind: .removed, text: text,
                                          oldNumber: oldNumber, newNumber: nil))
                oldNumber += 1
            case " ":
                diffLines.append(DiffLine(id: diffLines.count, kind: .context, text: text,
                                          oldNumber: oldNumber, newNumber: newNumber))
                oldNumber += 1
                newNumber += 1
            default:
                // "\ No newline at end of file"
                continue
            }
        }

        return diffLines
    }

    /// Start line of a "-14,9" or "+14" range.
    func startLine(of range: Substring) -> Int {
        Int(range.dropFirst().prefix(while: { $0 != "," })) ?? 0
    }
}
