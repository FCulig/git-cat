//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import SwiftUI

// MARK: - MainViewModel -
class MainViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var fileListWidth: CGFloat = 300
    
    let changesViewModel: ChangesViewModel
    let fileListViewModel: FileListViewModel
    let topBarViewModel: TopBarViewModel
    
    // MARK: - Initializer -
    
    init(changesViewModel: ChangesViewModel,
         fileListViewModel: FileListViewModel,
         topBarViewModel: TopBarViewModel) {
        self.changesViewModel = changesViewModel
        self.fileListViewModel = fileListViewModel
        self.topBarViewModel = topBarViewModel
        
        subscribeToSelectedFile()
        subscribeToFileListWidth()
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
    
    func subscribeToFileListWidth() {
        $fileListWidth
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink {
                print("Should save width: \($0)")
            }
            .store(in: &cancellables)
    }
}
