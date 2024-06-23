//
//  FileListViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import Foundation

// MARK: - FileListViewModel -
class FileListViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var isWorkspaceSelected: Bool
    @Published var selectedFile: File?
    
    let directorySelectionViewModel: DirectorySelectionViewModel
    let changedFilesListViewModel: ChangedFilesListViewModel
    
    // MARK: - Initializer -
    
    init(directorySelectionViewModel: DirectorySelectionViewModel,
         changedFilesListViewModel: ChangedFilesListViewModel) {
        self.directorySelectionViewModel = directorySelectionViewModel
        self.changedFilesListViewModel = changedFilesListViewModel
        
        isWorkspaceSelected = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) != nil
        
        subscribeFileSelection()
    }
}

// MARK: - Private methods -

private extension FileListViewModel {
    func subscribeFileSelection() {
        changedFilesListViewModel.$selectedFile
            .sink { [weak self] in self?.selectedFile = $0 }
            .store(in: &cancellables)
    }
}
