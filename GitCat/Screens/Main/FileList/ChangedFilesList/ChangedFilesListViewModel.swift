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
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var commitMessage = ""
    @Published var changedFiles: [ChangedFileListItemViewModel] = []
    @Published var selectedFile: File?
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        subscribeChanges()
        gitService.refreshChangedFiles()
        
        guard let firstChangedItem = changedFiles.first else {  return }
        select(itemViewModel: firstChangedItem)
    }
}

// MARK: - Public methods -

extension ChangedFilesListViewModel {
    func select(itemViewModel: ChangedFileListItemViewModel?) {
        selectedFile = itemViewModel?.file
        
        changedFiles.forEach { $0.isSelected = false }
        changedFiles.first(where: { $0 == itemViewModel })?.isSelected = true
    }
    
    func commitChanges(shouldPushChanges: Bool) {
        gitService.commit(message: commitMessage)
        commitMessage = ""
        
        if shouldPushChanges {
            gitService.push()
        }
    }
}

// MARK: - Private methods -

private extension ChangedFilesListViewModel {
    func subscribeChanges() {
        gitService.changedFiles
            .map { changedFiles in changedFiles.map(ChangedFileListItemViewModel.init)}
            .sink { [weak self] in
                guard let self else { return }
                self.changedFiles = $0
                
                guard let selectedFile = self.changedFiles.first(where: { $0.file.filePath == self.selectedFile?.filePath }) else {
                    self.select(itemViewModel: nil)
                    return
                }
                
                self.select(itemViewModel: selectedFile)
            }
            .store(in: &cancellables)
    }
}
