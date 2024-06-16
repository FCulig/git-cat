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
    
    @Published var upstreamCommitDifferece = ""
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
    func onAppear() {
        selectedFile = changedFiles.first
    }
    
    func commitChanges(shouldPushChanges: Bool) {
        gitService.commit(message: commitMessage)
        commitMessage = ""
        
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
        
        gitService.commitsComparedToUpstreamMessage
            .map { $0.contains("up to date") ? "" : $0 }
            .sink { [weak self] in self?.upstreamCommitDifferece = $0 }
            .store(in: &cancellables)
    }
}
