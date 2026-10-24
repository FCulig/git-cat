//
//  RootViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import OSLog
import SwiftUI

// MARK: - RootScreen -
enum RootScreen {
    case welcome
    case main
}

// MARK: - OpeningError -

/// Why opening a repository failed, shown in an alert on the welcome screen.
struct OpeningError {
    let repositoryName: String
    let message: String
}

// MARK: - RootViewModel -
final class RootViewModel: ObservableObject {
    // MARK: - Private properties -

    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    /// Keeps the loader up long enough not to flash past on fast repositories.
    private static let minimumOpeningDuration: TimeInterval = 0.6
    /// Time the finished loader stays up, so "Done" and the resting cat can be seen.
    private static let lingerAfterOpening: TimeInterval = 0.3
    private let gitService: GitService
    private let recentRepositoriesService: RecentRepositoriesService
    private let directorySelectionViewModel: DirectorySelectionViewModel

    // MARK: - Public properties -

    @Published private(set) var screen: RootScreen = .welcome
    /// Set while a repository is being opened.
    @Published private(set) var opening: OpeningProgress?
    @Published private(set) var openingError: OpeningError?

    let welcomeViewModel: WelcomeViewModel
    let mainViewModel: MainViewModel

    // MARK: - Initializer -

    init() {
        let shellService = ShellService()
        let fileService = FileService()
        let gitService = GitService(shellService: shellService)
        let recentRepositoriesService = RecentRepositoriesService(shellService: shellService, fileService: fileService)
        let directorySelectionViewModel = DirectorySelectionViewModel(fileService: fileService,
                                                                      gitService: gitService,
                                                                      recentRepositoriesService: recentRepositoriesService)
        let fileListViewModel = FileListViewModel(directorySelectionViewModel: directorySelectionViewModel,
                                                  changedFilesListViewModel: ChangedFilesListViewModel(gitService: gitService))

        self.gitService = gitService
        self.recentRepositoriesService = recentRepositoriesService
        self.directorySelectionViewModel = directorySelectionViewModel
        self.mainViewModel = MainViewModel(directorySelectionViewModel: directorySelectionViewModel,
                                           fileListViewModel: fileListViewModel,
                                           gitService: gitService)

        // Workspace selected before recents existed becomes the first recent repository.
        if recentRepositoriesService.currentRecents.isEmpty,
           let workspacePath = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey),
           fileService.isGitRepository(at: workspacePath) {
            recentRepositoriesService.add(path: workspacePath)
        }

        recentRepositoriesService.refresh()
        welcomeViewModel = WelcomeViewModel(recentRepositoriesService: recentRepositoriesService, fileService: fileService)
        welcomeViewModel.onOpen = { [weak self] in self?.open($0) }

        // Skip the welcome screen when the user asked to always open a repository at launch.
        if let autoOpenPath = recentRepositoriesService.autoOpenPath,
           let repository = recentRepositoriesService.currentRecents.first(where: { $0.path == autoOpenPath }) {
            open(repository)
        }
    }
}

// MARK: - Public methods -

extension RootViewModel {
    func open(_ repository: RecentRepository) {
        let repository = recentRepositoriesService.add(path: repository.path)
        UserDefaults.standard.setValue(repository.path, forKey: Self.workspacePathUserDefaultsKey)
        
        withAnimation(.easeOut(duration: 0.22)) {
            opening = OpeningProgress(repository: repository)
        }
        
        Task { @MainActor [weak self] in await self?.loadOpeningRepository() }
    }
    
    func dismissOpeningError() {
        openingError = nil
    }
}

// MARK: - Private methods -

private extension RootViewModel {
    @MainActor func loadOpeningRepository() async {
        guard let repository = opening?.repository else { return }
        
        do {
            for step in GitRefreshStep.allCases {
                try await gitService.refresh(step)
                opening?.finish(step)
            }
        } catch {
            Logger.navigation.error("Couldn't open \(repository.path): \(error.localizedDescription)")
            // Stay on the welcome screen, so another repository can be picked.
            withAnimation(.easeOut(duration: 0.22)) { opening = nil }
            openingError = OpeningError(repositoryName: repository.name, message: error.localizedDescription)
            return
        }
        guard let opening else { return }
        
        // Let the loader glide to 100%, but keep it up for at least the minimum duration.
        let shownFor = Date.now.timeIntervalSince(opening.startDate)
        let remaining = max(OpeningProgress.transitionDuration, Self.minimumOpeningDuration - shownFor)
        try? await Task.sleep(for: .seconds(remaining + Self.lingerAfterOpening))
        
        directorySelectionViewModel.isWorkspaceSelected = true
        withAnimation(.easeInOut(duration: 0.3)) {
            screen = .main
            self.opening = nil
        }
    }
}
