//
//  GitService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import Foundation

// MARK: - GitRefreshStep -

/// Parts of a full refresh, in the order they run. Opening a repository reports progress after each one.
enum GitRefreshStep: CaseIterable {
    case status
    case upstream
    case branches
    
    var title: String {
        switch self {
        case .status: "Reading status"
        case .upstream: "Comparing with origin"
        case .branches: "Loading branches"
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
    
    var currentBranch: AnyPublisher<String, Never> {
        currentBranchSubject.eraseToAnyPublisher()
    }
    
    var branches: AnyPublisher<[String], Never> {
        branchesSubject.eraseToAnyPublisher()
    }
    
    var changedFiles: AnyPublisher<[File], Never> {
        changedFilesSubject.eraseToAnyPublisher()
    }
    
    var commitsComparedToUpstream: AnyPublisher<Int, Never> {
        commitsComparedToUpstreamSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private properties -
    
    private let shellService: ShellService
    private let currentBranchSubject: PassthroughSubject<String, Never> = .init()
    private let branchesSubject: PassthroughSubject<[String], Never> = .init()
    private let changedFilesSubject: CurrentValueSubject<[File], Never> = .init([])
    private let commitsComparedToUpstreamSubject: PassthroughSubject<Int, Never> = .init()
    
    // MARK: - Initializer -
    
    init(shellService: ShellService) {
        self.shellService = shellService
    }
}

// MARK: - Public methods -

extension GitService {
    /// Refreshes everything on the calling thread. Steps that fail keep their previously published values.
    func refreshChangedFiles() {
        GitRefreshStep.allCases.forEach { step in
            if let result = try? load(step) { publish(result) }
        }
    }
    
    /// Runs the step's git commands on a background thread, then publishes the result on the main thread.
    /// Throws `GitError` when git fails, e.g. because the directory is no longer a repository.
    @MainActor func refresh(_ step: GitRefreshStep) async throws {
        let result = try await Task.detached(priority: .userInitiated) { [self] in try load(step) }.value
        publish(result)
    }
    
    func getChangesFor(file: File) -> String {
        // TODO: Factory for this making of commands or something else?
        let output = shellService.execute("\(GitCommands.diff.rawValue) \(file.isStaged ? "--staged" : "") \(file.filePath)")
        return parseGitDiffOutput(output)
    }
    
    func stage(file: File) {
        shellService.execute("\(GitCommands.add.rawValue) \(file.filePath)")
        refreshChangedFiles()
    }
    
    func unstage(file: File) {
        shellService.execute("\(GitCommands.restore.rawValue) \(file.filePath)")
        refreshChangedFiles()
    }
    
    func commit(message: String) {
        shellService.execute("\(GitCommands.commit.rawValue) '\(message)'")
        refreshChangedFiles()
    }
    
    func push() {
        shellService.execute("\(GitCommands.push.rawValue)")
        refreshChangedFiles()
    }
}

// MARK: - Private methods -

private extension GitService {
    enum RefreshResult {
        case changedFiles([File])
        case commitsComparedToUpstream(Int)
        case branches([String])
    }
    
    /// Only runs commands and parses their output, so it is safe to call from any thread.
    func load(_ step: GitRefreshStep) throws -> RefreshResult {
        switch step {
        case .status:
            .changedFiles(parseGitStatusShortOutput(try run("\(GitCommands.status.rawValue) --short")))
        case .upstream:
            .commitsComparedToUpstream(numberOfCommitsComparedToUpstream())
        case .branches:
            .branches(parseBranchList(try run(GitCommands.listOfBranches.rawValue)))
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
    
    func publish(_ result: RefreshResult) {
        switch result {
        case .changedFiles(let files):
            changedFilesSubject.send(files)
        case .commitsComparedToUpstream(let count):
            commitsComparedToUpstreamSubject.send(count)
        case .branches(let branches):
            branchesSubject.send(branches)
        }
    }
    
    /// Negative when behind the upstream, positive when only ahead of it, 0 when in sync or there is no upstream
    /// (e.g. no remote, or a branch that was never pushed).
    func numberOfCommitsComparedToUpstream() -> Int {
        let result = shellService.run(GitCommands.upstreamComparison.rawValue)
        guard result.succeeded else { return 0 }
        
        let counts = result.output.split(whereSeparator: \.isWhitespace).compactMap { Int($0) }
        guard counts.count == 2 else { return 0 }
        
        let (ahead, behind) = (counts[0], counts[1])
        return behind > 0 ? -behind : ahead
    }
}

// MARK: - Parsing git branch list -

private extension GitService {
    // Example output (tab separated):
    // main
    // origin/HEAD    refs/remotes/origin/main
    // origin/main
    //
    // Symbolic refs like origin/HEAD only point to another branch, so they are skipped.
    func parseBranchList(_ output: String) -> [String] {
        output.split(separator: "\n").compactMap { line in
            let columns = line.split(separator: "\t", omittingEmptySubsequences: false)
            guard let name = columns.first, !name.isEmpty, columns.dropFirst().allSatisfy(\.isEmpty) else { return nil }
            return String(name)
        }
    }
}

// MARK: - Parsing git status output -

private extension GitService {
    // Example output:
    // M  GitCat/Models/File.swift
    //  M GitCat/Services/GitService.swift
    //
    // File.swift is modified and the change is staged.
    // GitService.swift is modified and the change is not staged.
    func parseGitStatusShortOutput(_ output: String) -> [File] {
        var files: [File] = []
        
        // TODO: Doesnt work when splitted into map
        output.split(separator: "\n")
            .forEach {
                var line = $0
                
                guard let indexStatusCharacter = line.first,
                let indexStatus = FileStatus(rawValue: String(indexStatusCharacter)) else { return }
                line.removeFirst()
                
                guard let workingTreeStatusCharacter = line.first,
                let workingTreeStatus = FileStatus(rawValue: String(workingTreeStatusCharacter)) else { return }
                line.removeFirst()
                
                var filePath = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if filePath.contains(" -> ") {
                    filePath = String(filePath.split(separator: " -> ")[1])
                }
                
                files.append(File(filePath: filePath, indexStatus: indexStatus, workingTreeStatus: workingTreeStatus))
            }
        
        return files
    }
}

// MARK: - Parsing git diff output -

private extension GitService {
    func parseGitDiffOutput(_ output: String) -> String {
        // TODO: Implement parsing
        return output
    }
}
