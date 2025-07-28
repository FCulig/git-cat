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
    @Published var selectedItem: MainMenuItem = .workingDirectory
    @Published var changesViewModel: ChangesViewModel?
    
    let mainMenuViewModel: MainMenuViewModel
    let directorySelectionViewModel: DirectorySelectionViewModel
    let fileListViewModel: FileListViewModel
    
    // MARK: - Initializer -
    
    init(directorySelectionViewModel: DirectorySelectionViewModel,
         fileListViewModel: FileListViewModel,
         gitService: GitService) {
        self.mainMenuViewModel = MainMenuViewModel()
        self.fileListViewModel = fileListViewModel
        self.directorySelectionViewModel = directorySelectionViewModel
        
        setRepoName()
        
        gitService.changedFiles
            .sink { [weak self] _ in self?.setRepoName() }
            .store(in: &cancellables)
        
        mainMenuViewModel.$selectedItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.selectedItem = $0 }
            .store(in: &cancellables)
        
        fileListViewModel.changedFilesListViewModel.$selectedFile
            .compactMap { $0?.file }
            .sink { [weak self] file in
                DispatchQueue.main.async {
                    self?.changesViewModel = .init(changedFile: file, gitService: gitService)
                }
            }
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
