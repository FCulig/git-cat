//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - MainViewModel -
class MainViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    let changesViewModel: ChangesViewModel
    let fileListViewModel: FileListViewModel
    
    // MARK: - Initializer -
    
    init(changesViewModel: ChangesViewModel,
         fileListViewModel: FileListViewModel) {
        self.changesViewModel = changesViewModel
        self.fileListViewModel = fileListViewModel
        
        subscribeToSelectedFile()
    }
}

// MARK: - Private methods -

private extension MainViewModel {
    func subscribeToSelectedFile() {
        fileListViewModel.$selectedFile
            .sink { [weak self] in
                self?.changesViewModel.getChangesIn(file: $0)
            }
            .store(in: &cancellables)
    }
}
