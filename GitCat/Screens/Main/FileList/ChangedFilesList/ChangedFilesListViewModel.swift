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
    
    @Published var changedFiles: [ChangedFileListItemViewModel] = []
    @Published var selectedFile: File?
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        changedFiles = gitService.getChangedFiles()
            .map {
                ChangedFileListItemViewModel(file: $0)
            }
    }
}

// MARK: - Public methods -

extension ChangedFilesListViewModel {
    func select(itemViewModel: ChangedFileListItemViewModel) {
        selectedFile = itemViewModel.file
        
        changedFiles.forEach { $0.isSelected = false }
        changedFiles.first(where: { $0 == itemViewModel })?.isSelected = true
    }
}
