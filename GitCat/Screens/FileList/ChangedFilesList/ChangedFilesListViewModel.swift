//
//  ChangedFilesListViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - ChangedFilesListViewModel -
class ChangedFilesListViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var upstreamCommitDiffereceMessage: String?
    @Published var commitMessage = ""
    @Published var changedFiles: [File] = []
    @Published var selectedFile: File?
    let gitService: GitService
    
    // MARK: - Initializer -
    
    init(gitService: GitService) {
        self.gitService = gitService
        
        subscribeChanges()
    }
}

// MARK: - Public methods -

extension ChangedFilesListViewModel {
    func pushChanges() {
        gitService.push()
    }
    
    func commitChanges(shouldPushChanges: Bool) {
        gitService.commit(message: commitMessage)
        commitMessage = ""
        selectedFile = nil
        
        if shouldPushChanges {
            gitService.push()
        }
    }
}

// MARK: - Private methods -

private extension ChangedFilesListViewModel {
    func subscribeChanges() {
        gitService.changedFiles
            .sink { [weak self] in self?.changedFiles = $0 }
            .store(in: &cancellables)
        
        gitService.commitsComparedToUpstream
            .removeDuplicates()
            .map { (numberOfCommits) -> String? in
                if numberOfCommits == 0 {
                    return nil
                } else if numberOfCommits > 0 {
                    return "Your branch is \(numberOfCommits) commit ahead of the upstream."
                } else {
                    return "Your branch is \(numberOfCommits) commit behind of the upstream."
                }
            }
            .sink { [weak self] in self?.upstreamCommitDiffereceMessage = $0 }
            .store(in: &cancellables)
    }
}
