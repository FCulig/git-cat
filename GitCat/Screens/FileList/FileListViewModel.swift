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
    
    let directorySelectionViewModel: DirectorySelectionViewModel
    let changedFilesListViewModel: ChangedFilesListViewModel
    
    // MARK: - Initializer -
    
    init(directorySelectionViewModel: DirectorySelectionViewModel,
         changedFilesListViewModel: ChangedFilesListViewModel) {
        self.directorySelectionViewModel = directorySelectionViewModel
        self.changedFilesListViewModel = changedFilesListViewModel
        
        isWorkspaceSelected = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) != nil
    }
}
