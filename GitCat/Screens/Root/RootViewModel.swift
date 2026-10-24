//
//  RootViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - RootScreen -
enum RootScreen {
    case welcome
    case main
}

// MARK: - RootViewModel -
final class RootViewModel: ObservableObject {
    // MARK: - Private properties -

    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private let gitService: GitService
    private let recentRepositoriesService: RecentRepositoriesService
    private let directorySelectionViewModel: DirectorySelectionViewModel

    // MARK: - Public properties -

    @Published private(set) var screen: RootScreen = .welcome
    @Published private(set) var openingRepository: RecentRepository?

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
            openingRepository = repository
        }
    }

    func openingDidFinish() {
        gitService.refreshChangedFiles()
        directorySelectionViewModel.isWorkspaceSelected = true

        withAnimation(.easeInOut(duration: 0.3)) {
            screen = .main
            openingRepository = nil
        }
    }
}
