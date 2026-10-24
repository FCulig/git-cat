//
//  DirectorySelectionViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 23.06.2024..
//

import AppKit
import Foundation

// MARK: - DirectorySelectionViewModel
final class DirectorySelectionViewModel: ObservableObject {
    // MARK: - Private properties
    
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private let fileService: FileService
    private let gitService: GitService
    private let recentRepositoriesService: RecentRepositoriesService
    
    // MARK: - Public properties
    
    @Published var isWorkspaceSelected: Bool
    @Published var isShowingInvalidWorkspaceAlert = false
    
    // MARK: - Initializer
    
    init(fileService: FileService,
         gitService: GitService,
         recentRepositoriesService: RecentRepositoriesService) {
        self.fileService = fileService
        self.gitService = gitService
        self.recentRepositoriesService = recentRepositoriesService
        
        isWorkspaceSelected = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) != nil
    }
}

// MARK: - Public methods

extension DirectorySelectionViewModel {
    func showOpenPanel() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select your workspace"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        let panelResult = openPanel.runModal()
        
        if panelResult != .OK { return }
        
        guard panelResult == .OK,
              let url = openPanel.url?.path(),
              isValid(directory: url) else {
            isShowingInvalidWorkspaceAlert = true
            return
        }
        
        UserDefaults.standard.setValue(url, forKey: Self.workspacePathUserDefaultsKey)
        recentRepositoriesService.add(path: url)
        isWorkspaceSelected = true
        gitService.refreshChangedFiles()
    }
}

// MARK: - Private methods

private extension DirectorySelectionViewModel {
    func isValid(directory url: String) -> Bool {
        fileService.isGitRepository(at: url)
    }
}
