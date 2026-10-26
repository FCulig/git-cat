//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - MainViewModel -
@MainActor
final class MainViewModel: ObservableObject {
    // MARK: - Public properties -
    
    let sidebarViewModel: SidebarViewModel
    let workingCopyViewModel: WorkingCopyViewModel
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        sidebarViewModel = SidebarViewModel(gitService: gitService)
        workingCopyViewModel = WorkingCopyViewModel(gitService: gitService)
    }
}
