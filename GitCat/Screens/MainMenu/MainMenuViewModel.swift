//
//  MainMenuViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 25.05.2024..
//

import Foundation

// MARK: - MainMenuViewModel -
final class MainMenuViewModel: ObservableObject {
    // MARK: - Public properties -
    
    let fileListViewModel: FileListViewModel
    
    // MARK: - Initializer -
    
    init(fileListViewModel: FileListViewModel) {
        self.fileListViewModel = fileListViewModel
    }
}
