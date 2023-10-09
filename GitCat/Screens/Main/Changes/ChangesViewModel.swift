//
//  ChangesViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - ChangesViewModel -
class ChangesViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private let gitService: GitService
    
    // MARK: - Public properties -
    
    @Published var changes: String = ""
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
    }
}

// MARK: - Public methods -

extension ChangesViewModel {
    func getChangesIn(file: File?) {
        guard let file else {
            changes = ""
            return
        }
        
        changes = gitService.getChangesFor(file: file)
    }
}
