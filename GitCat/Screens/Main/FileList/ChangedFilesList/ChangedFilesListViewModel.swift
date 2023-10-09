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
    @Published var selectedFile: File?
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        changedFiles = gitService.getChangedFiles()
    }
}

// MARK: - Public methods -

extension ChangedFilesListViewModel {
    func select(file: File) {
        selectedFile = file
    }
}
