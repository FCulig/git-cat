//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - MainViewModel -
class MainViewModel: ObservableObject {
    let changesViewModel: ChangesViewModel
    let fileListViewModel: FileListViewModel
    
    init(changesViewModel: ChangesViewModel,
         fileListViewModel: FileListViewModel) {
        self.changesViewModel = changesViewModel
        self.fileListViewModel = fileListViewModel
    }
}
