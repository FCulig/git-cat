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
    
//    @Published var changes: [Substring] = []
    @Published var changes: [Change] = []
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
    }
}

// MARK: - Public methods -

extension ChangesViewModel {
    func getChangesIn(file: File?) {
        guard let file else {
            changes = []
            return
        }
        
        var changesStringByLine = gitService.getChangesFor(file: file).split(separator: "\n")
        let firstChangeIndex = changesStringByLine.firstIndex(where: { $0.starts(with: "@@") })
        
        guard let firstChangeIndex else { return }
        changesStringByLine.removeFirst(firstChangeIndex)
        
        var change = ""
        var tmpChanges: [Change] = []
        changesStringByLine.forEach {
            if $0.starts(with: "@@"), change != "" {
                tmpChanges.append(Change(change: change))
                change = ""
            }
            
            change += $0 + "\n"
        }
        
        tmpChanges.append(Change(change: change))
        changes = tmpChanges
    }
}
