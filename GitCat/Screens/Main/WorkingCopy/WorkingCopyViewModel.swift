//
//  WorkingCopyViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Combine
import SwiftUI

// MARK: - WorkingCopyOperation -

enum WorkingCopyOperation {
    case fetch
    case pull
    case push
    case commit
}

// MARK: - WorkingCopyViewModel -

@MainActor
final class WorkingCopyViewModel: ObservableObject {
    // MARK: - Private properties -

    private static let toastDuration: Duration = .seconds(2.6)
    private static let listAnimation = Animation.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.38)
    private let gitService: GitService
    private var cancellables: Set<AnyCancellable> = []
    private var toastTask: Task<Void, Never>?

    // MARK: - Public properties -

    /// `nil` on a detached HEAD.
    @Published private(set) var branchName: String?
    @Published private(set) var stagedFiles: [ChangedFile] = []
    @Published private(set) var unstagedFiles: [ChangedFile] = []
    @Published private(set) var upstream: UpstreamStatus?
    @Published private(set) var remotes: [String] = []
    @Published private(set) var lastCommit: CommitSummary?
    @Published private(set) var selectedFile: ChangedFile?
    @Published private(set) var diffViewModel: DiffViewModel?
    @Published private(set) var operation: WorkingCopyOperation?
    @Published private(set) var toast: String?
    @Published var summary = ""
    @Published var commitDescription = ""
    @Published var pushesAfterCommit = false
    /// File waiting for the user to confirm that its changes should be thrown away.
    @Published var fileToDiscard: ChangedFile?

    // MARK: - Initializer -

    init(gitService: GitService) {
        self.gitService = gitService

        subscribeToRepository()
    }
}

// MARK: - Labels -

extension WorkingCopyViewModel {
    var branchTitle: String {
        branchName ?? "Detached HEAD"
    }

    var remoteName: String {
        upstream?.remote ?? (remotes.contains("origin") ? "origin" : remotes.first ?? "origin")
    }

    var syncTitle: String {
        guard let upstream else {
            return remotes.isEmpty ? "No remote" : "Not published to \(remoteName)"
        }
        switch (upstream.ahead, upstream.behind) {
        case (0, 0): return "Up to date with \(upstream.remote)"
        case (let ahead, 0): return "\(ahead) ahead of \(upstream.remote)"
        case (0, let behind): return "\(behind) behind \(upstream.remote)"
        case (let ahead, let behind): return "\(ahead) ahead, \(behind) behind \(upstream.remote)"
        }
    }

    var commitsToPush: Int {
        upstream?.ahead ?? 0
    }

    var pushTitle: String {
        operation == .push ? "Pushing…" : (commitsToPush > 0 ? "Push \(commitsToPush)" : "Push")
    }

    var fetchTitle: String {
        operation == .fetch ? "Fetching…" : "Fetch"
    }

    var pullTitle: String {
        operation == .pull ? "Pulling…" : "Pull"
    }

    var pushDestination: String {
        upstream?.name ?? "\(remoteName)/\(branchTitle)"
    }

    var changedFileCount: Int {
        Set((stagedFiles + unstagedFiles).map(\.path)).count
    }

    var isClean: Bool {
        stagedFiles.isEmpty && unstagedFiles.isEmpty
    }

    var changesSubtitle: String {
        guard !isClean else { return "Nothing to commit" }
        return "\(changedFileCount) file\(changedFileCount == 1 ? "" : "s") changed on \(branchTitle)"
    }

    var canCommit: Bool {
        !stagedFiles.isEmpty && !summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && operation == nil
    }

    var commitTitle: String {
        let action = pushesAfterCommit ? "Commit & Push" : "Commit"
        guard !stagedFiles.isEmpty else { return action }
        return "\(action) \(stagedFiles.count) File\(stagedFiles.count == 1 ? "" : "s")"
    }

    var cleanSubtitle: String {
        guard let lastCommit else { return "No commits yet" }
        return "Last commit \(lastCommit.hash) — \(lastCommit.message)"
    }

    var pushCommitsTitle: String {
        "Push \(commitsToPush) commit\(commitsToPush == 1 ? "" : "s") to \(remoteName)"
    }

    var fetchedMessage: String {
        guard let upstream else { return "Fetched from \(remoteName)" }
        switch upstream.behind {
        case 0: return "Up to date with \(upstream.remote)"
        case 1: return "1 new commit on \(upstream.remote)"
        default: return "\(upstream.behind) new commits on \(upstream.remote)"
        }
    }
}

// MARK: - Public methods -

extension WorkingCopyViewModel {
    func select(_ file: ChangedFile) {
        guard file.id != selectedFile?.id else { return }
        selectedFile = file
        diffViewModel = DiffViewModel(file: file, gitService: gitService)
    }

    func toggleStage(_ file: ChangedFile) {
        if file.isStaged {
            perform { [gitService] in try await gitService.unstage([file]) }
        } else {
            perform { [gitService] in try await gitService.stage([file]) }
        }
    }

    func toggleStageOfSelectedFile() {
        guard let selectedFile else { return }
        toggleStage(selectedFile)
    }

    func stageAll() {
        let files = unstagedFiles
        perform { [gitService] in try await gitService.stage(files) }
    }

    func unstageAll() {
        let files = stagedFiles
        perform { [gitService] in try await gitService.unstage(files) }
    }

    func requestDiscard(_ file: ChangedFile) {
        fileToDiscard = file
    }

    func requestDiscardOfSelectedFile() {
        fileToDiscard = selectedFile
    }

    func discard(_ file: ChangedFile) {
        fileToDiscard = nil
        perform(successMessage: { _ in "Changes discarded" }) { [gitService] in try await gitService.discard(file) }
    }

    func commit() {
        guard canCommit else { return }
        let summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        let description = commitDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        let pushes = pushesAfterCommit

        perform(.commit, successMessage: { viewModel in
            viewModel.summary = ""
            viewModel.commitDescription = ""
            // Pushing shows its own toast once it's done.
            if pushes {
                viewModel.push()
                return nil
            }
            return "Committed \(viewModel.lastCommit?.hash ?? "") to \(viewModel.branchTitle)"
        }) { [gitService] in
            try await gitService.commit(summary: summary, description: description)
        }
    }

    func fetch() {
        perform(.fetch, successMessage: { $0.fetchedMessage }) { [gitService] in
            try await gitService.fetch()
        }
    }

    func pull() {
        perform(.pull, successMessage: { "Pulled from \($0.remoteName)" }) { [gitService] in
            try await gitService.pull()
        }
    }

    func push() {
        perform(.push, successMessage: { "Pushed to \($0.pushDestination)" }) { [gitService] in
            try await gitService.push()
        }
    }
}

// MARK: - Private methods -

private extension WorkingCopyViewModel {
    func subscribeToRepository() {
        gitService.changedFiles
            .removeDuplicates()
            .sink { [weak self] in self?.update(files: $0) }
            .store(in: &cancellables)

        gitService.currentBranch
            .sink { [weak self] in self?.branchName = $0 }
            .store(in: &cancellables)

        gitService.upstream
            .sink { [weak self] in self?.upstream = $0 }
            .store(in: &cancellables)

        gitService.remotes
            .sink { [weak self] in self?.remotes = $0 }
            .store(in: &cancellables)

        gitService.history
            .sink { [weak self] in self?.lastCommit = $0.lastCommit }
            .store(in: &cancellables)
    }

    func update(files: [ChangedFile]) {
        let previousFile = selectedFile
        let previousList = previousFile?.isStaged == true ? stagedFiles : unstagedFiles

        withAnimation(Self.listAnimation) {
            stagedFiles = files.filter(\.isStaged)
            unstagedFiles = files.filter { !$0.isStaged }
        }

        // When a file is staged, unstaged or discarded, the next file in the same list gets selected. Once that list
        // is empty, the file stays selected on its new side of the index.
        let allFiles = stagedFiles + unstagedFiles
        let nextFile = previousFile.flatMap { previous in
            allFiles.first { $0.id == previous.id }
                ?? neighbor(of: previous, in: previousList, remaining: previous.isStaged ? stagedFiles : unstagedFiles)
                ?? allFiles.first { $0.path == previous.path }
        } ?? allFiles.first

        selectedFile = nextFile
        if let nextFile, let diffViewModel, nextFile.id == previousFile?.id {
            diffViewModel.reload(file: nextFile)
        } else {
            diffViewModel = nextFile.map { DiffViewModel(file: $0, gitService: gitService) }
        }
    }

    /// File that followed the given one in the list it was in, or preceded it when it was last, that's still in the list.
    func neighbor(of file: ChangedFile, in previousFiles: [ChangedFile], remaining files: [ChangedFile]) -> ChangedFile? {
        guard let index = previousFiles.firstIndex(where: { $0.id == file.id }) else { return nil }
        let candidates = Array(previousFiles[(index + 1)...]) + previousFiles[..<index].reversed()
        return candidates.lazy
            .compactMap { candidate in files.first { $0.id == candidate.id } }
            .first
    }

    /// Runs the work, then shows the success message or the error in a toast.
    /// - Parameters:
    ///   - operation: Shown as running while the work runs. Nothing happens when another operation is running.
    ///   - successMessage: Called once the work succeeded. Returns the toast to show, if any.
    func perform(_ operation: WorkingCopyOperation? = nil,
                 successMessage: ((WorkingCopyViewModel) -> String?)? = nil,
                 work: @escaping @MainActor () async throws -> Void) {
        if let operation {
            guard self.operation == nil else { return }
            self.operation = operation
        }

        Task { [weak self] in
            do {
                try await work()
                guard let self else { return }
                if operation != nil { self.operation = nil }
                if let message = successMessage?(self) {
                    showToast(message)
                }
            } catch {
                guard let self else { return }
                if operation != nil { self.operation = nil }
                showToast(error.localizedDescription)
            }
        }
    }

    func showToast(_ message: String) {
        toastTask?.cancel()
        withAnimation(.spring(response: 0.42, dampingFraction: 0.7)) { toast = message }

        toastTask = Task { [weak self] in
            try? await Task.sleep(for: Self.toastDuration)
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.2)) { self?.toast = nil }
        }
    }
}
