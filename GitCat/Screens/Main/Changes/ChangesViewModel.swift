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
    
    private let changedFile: File?
    private let gitService: GitService
    
    // MARK: - Public properties -
    
    @Published var changes: [Change] = []
    @Published var isFileStaged: Bool = false
    
    // MARK: - Initializer -
    
    init(changedFile: File, gitService: GitService) {
        self.changedFile = changedFile
        self.gitService = gitService
        
        isFileStaged = changedFile.isStaged
        updateFileChanges(for: changedFile)
    }
}

// MARK: - Public methods -

extension ChangesViewModel {
    func stageFile() {
        guard let changedFile else { return }
        
        gitService.stage(file: changedFile)
        updateFileChanges(for: changedFile)
        isFileStaged = true
    }
    
    func unstageFile() {
        guard let changedFile else { return }
        
        gitService.unstage(file: changedFile)
        updateFileChanges(for: changedFile)
        isFileStaged = false
    }
}

// MARK: - Private methods -

private extension ChangesViewModel {
    func updateFileChanges(for file: File) {
        var changesStringByLine = gitService.getChangesFor(file: file).split(separator: "\n")
        let firstChangeIndex = changesStringByLine.firstIndex(where: { $0.starts(with: "@@") })
        
        guard let firstChangeIndex else { return }
        changesStringByLine.removeFirst(firstChangeIndex)
        
        var change = ""
        var tmpChanges: [Change] = []
        changesStringByLine.forEach {
            if $0.starts(with: "@@"), change != "" {
                tmpChanges.append(Change(changeChunk: change))
                change = ""
            }
            
            change += $0 + "\n"
        }
        
        tmpChanges.append(Change(changeChunk: change))
        changes = tmpChanges
    }
}
