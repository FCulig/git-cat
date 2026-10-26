//
//  DiffViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Combine
import OSLog

// MARK: - DiffViewModel -
@MainActor
final class DiffViewModel: ObservableObject {
    // MARK: - Private properties -

    private let gitService: GitService
    private var loadingTask: Task<Void, Never>?

    // MARK: - Public properties -

    @Published private(set) var file: ChangedFile
    @Published private(set) var lines: [DiffLine] = []
    @Published private(set) var isLoading = true
    @Published private(set) var errorMessage: String?

    var statusTitle: String {
        file.status.title + (file.isStaged ? " · Staged" : "")
    }

    var directoryTitle: String {
        file.directory ?? "Repository root"
    }

    var isEmpty: Bool {
        !isLoading && errorMessage == nil && lines.isEmpty
    }

    var emptyMessage: String {
        if let originalPath = file.originalPath {
            return "\(file.status == .copied ? "Copied" : "Renamed") from \(originalPath), without changes to its contents."
        }
        return "Binary file, there are no lines to show."
    }

    // MARK: - Initializer -

    init(file: ChangedFile, gitService: GitService) {
        self.file = file
        self.gitService = gitService

        reload(file: file)
    }
}

// MARK: - Public methods -

extension DiffViewModel {
    func reload(file: ChangedFile) {
        self.file = file
        loadingTask?.cancel()
        loadingTask = Task { [weak self, gitService] in
            do {
                let lines = try await gitService.diff(for: file)
                guard !Task.isCancelled else { return }
                self?.lines = lines
                self?.errorMessage = nil
            } catch {
                guard !Task.isCancelled else { return }
                Logger.git.error("Couldn't load diff of \(file.path): \(error.localizedDescription)")
                self?.lines = []
                self?.errorMessage = error.localizedDescription
            }
            self?.isLoading = false
        }
    }
}
