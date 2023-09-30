//
//  ChangedFilesListViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - ChangedFilesListViewModel -
class ChangedFilesListViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private let gitService: GitService
    
    // MARK: - Public properties -
    
    @Published var changedFiles: [File] = []
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        changedFiles = gitService.getChangedFiles()
        changedFiles.forEach{ print($0) }
    }
}
