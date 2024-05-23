//
//  TopBarViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 23.05.2024..
//

import Combine

// MARK: - TopBarViewModel -
final class TopBarViewModel: ObservableObject {
    // MARK: - Public properties -
    
    @Published var currentBranch: String = ""
    
    // MARK: - Private properties -
    
    private let gitService: GitService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        subscribeChanges()
    }
}

// MARK: - Private methods -

private extension TopBarViewModel {
    func subscribeChanges() {
        gitService.currentBranch
            .sink { [weak self] in self?.currentBranch = $0 }
            .store(in: &cancellables)
    }
}
