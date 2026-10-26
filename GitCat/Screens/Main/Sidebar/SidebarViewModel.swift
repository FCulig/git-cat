//
//  SidebarViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Combine
import Foundation

// MARK: - SidebarViewModel -
@MainActor
final class SidebarViewModel: ObservableObject {
    // MARK: - Private properties -

    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Public properties -

    @Published private(set) var repositoryName = ""
    @Published private(set) var repositoryPath = ""
    @Published private(set) var selectedItem: SidebarItem = .changes
    @Published private(set) var changedFileCount = 0
    @Published private(set) var commitCount = 0
    @Published private(set) var currentBranch: String?
    @Published private(set) var branches: [String] = []
    @Published private(set) var remotes: [String] = []

    // MARK: - Initializer -

    init(gitService: GitService) {
        gitService.changedFiles
            .sink { [weak self] files in
                self?.changedFileCount = Set(files.map(\.path)).count
                self?.updateRepository()
            }
            .store(in: &cancellables)

        gitService.history
            .map(\.commitCount)
            .sink { [weak self] in self?.commitCount = $0 }
            .store(in: &cancellables)

        gitService.currentBranch
            .combineLatest(gitService.branches)
            .sink { [weak self] currentBranch, branches in
                self?.currentBranch = currentBranch
                // Before the first commit the current branch exists only in HEAD, so it isn't listed by git.
                self?.branches = (currentBranch.map { [$0] } ?? []) + branches.filter { $0 != currentBranch }
            }
            .store(in: &cancellables)

        gitService.remotes
            .sink { [weak self] in self?.remotes = $0 }
            .store(in: &cancellables)
    }
}

// MARK: - Public methods -

extension SidebarViewModel {
    func select(_ item: SidebarItem) {
        guard item.isAvailable else { return }
        selectedItem = item
    }

    func count(for item: SidebarItem) -> Int? {
        switch item {
        case .changes: changedFileCount > 0 ? changedFileCount : nil
        case .history: commitCount
        case .stashes: nil
        }
    }
}

// MARK: - Private methods -

private extension SidebarViewModel {
    func updateRepository() {
        let path = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) ?? ""
        let url = URL(fileURLWithPath: path)
        repositoryName = url.lastPathComponent
        repositoryPath = (url.path as NSString).abbreviatingWithTildeInPath
    }
}
