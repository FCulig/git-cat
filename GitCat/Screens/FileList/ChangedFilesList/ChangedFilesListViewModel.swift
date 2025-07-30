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
    
    @Published var upstreamCommitDifferenceMessage: String?
    @Published var commitMessage = ""
    @Published var changedFiles: [ChangedFileListItemViewModel] = []
    @Published var selectedFile: ChangedFileListItemViewModel?
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
        
        guard shouldPushChanges else { return }
        gitService.push()
    }
}

// MARK: - Private methods -

private extension ChangedFilesListViewModel {
    func subscribeChanges() {
        gitService.changedFiles
            .removeDuplicates()
            .sink { [weak self] in
                guard let self else { return }
                self.changedFiles = $0.map { ChangedFileListItemViewModel(file: $0) }
            }
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
            .sink { [weak self] in self?.upstreamCommitDifferenceMessage = $0 }
            .store(in: &cancellables)
    }
}
