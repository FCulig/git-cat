//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import SwiftUI

// MARK: - MainViewModel -
class MainViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var repoName: String = ""
        
    let mainMenuViewModel: MainMenuViewModel
    let topBarViewModel: TopBarViewModel
    let directorySelectionViewModel: DirectorySelectionViewModel
    
    // MARK: - Initializer -
    
    init(mainMenuViewModel: MainMenuViewModel,
         topBarViewModel: TopBarViewModel,
         directorySelectionViewModel: DirectorySelectionViewModel,
         gitService: GitService) {
        self.mainMenuViewModel = mainMenuViewModel
        self.topBarViewModel = topBarViewModel
        self.directorySelectionViewModel = directorySelectionViewModel
        
        setRepoName()
        
        gitService.changedFiles
            .sink { [weak self] _ in self?.setRepoName() }
            .store(in: &cancellables)
    }
}

// MARK: - Private methods

private extension MainViewModel {
    func setRepoName() {
        let repoPath = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey)
        repoName = String(repoPath?.split(separator: "/").last ?? "")
    }
}
