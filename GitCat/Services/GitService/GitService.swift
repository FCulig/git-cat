//
//  GitService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine

// MARK: - GitService -
class GitService {
    // MARK: - Public properties -
    
    var currentBranch: AnyPublisher<String, Never> {
        currentBranchSubject.eraseToAnyPublisher()
    }
    
    var changedFiles: AnyPublisher<[File], Never> {
        changedFilesSubject.eraseToAnyPublisher()
    }
    
    var commitsComparedToUpstreamMessage: AnyPublisher<String, Never> {
        commitsComparedToUpstreamMessageSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private properties -
    
    private let shellService: ShellService
    private let currentBranchSubject: PassthroughSubject<String, Never> = .init()
    private let changedFilesSubject: CurrentValueSubject<[File], Never> = .init([])
    private let commitsComparedToUpstreamMessageSubject: PassthroughSubject<String, Never> = .init()
    
    // MARK: - Initializer -
    
    init(shellService: ShellService) {
        self.shellService = shellService
    }
}

// MARK: - Public methods -

extension GitService {
    func refreshChangedFiles() {
        let output = shellService.execute("\(GitCommands.status.rawValue) --short")
        changedFilesSubject.send(parseGitStatusShortOutput(output))
        updateNumberOfCommitsComparedToUpstream()
    }
    
    func getChangesFor(file: File) -> String {
        // TODO: Factory for this making of commands?
        let output = shellService.execute("\(GitCommands.diff.rawValue) \(file.isStaged ? "--staged" : "") \(file.filePath)")
        return parseGitDiffOutput(output)
    }
    
    func stage(file: File) {
        shellService.execute("\(GitCommands.add.rawValue) \(file.filePath)")
        refreshChangedFiles()
    }
    
    func unstage(file: File) {
        shellService.execute("\(GitCommands.restore.rawValue) \(file.filePath)")
        refreshChangedFiles()
    }
    
    func commit(message: String) {
        shellService.execute("\(GitCommands.commit.rawValue) '\(message)'")
        refreshChangedFiles()
    }
    
    func push() {
        shellService.execute("\(GitCommands.push.rawValue)")
        refreshChangedFiles()
    }
}

// MARK: - Private methods -

private extension GitService {
    func updateNumberOfCommitsComparedToUpstream() {
        let output = shellService.execute(GitCommands.status.rawValue)
        parseGitStatusOutput(output)
    }
}

// MARK: - Parsing git status output -

private extension GitService {
    // Example output:
    // M  GitCat/Models/File.swift
    //  M GitCat/Services/GitService.swift
    //
    // File.swift is modified and the change is staged.
    // GitService.swift is modified and the change is not staged.
    func parseGitStatusShortOutput(_ output: String) -> [File] {
        var files: [File] = []
        
        // TODO: Doesnt work when splitted into map
        output.split(separator: "\n")
            .forEach {
                var line = $0
                
                guard let indexStatusCharacter = line.first,
                let indexStatus = FileStatus(rawValue: String(indexStatusCharacter)) else { return }
                line.removeFirst()
                
                guard let workingTreeStatusCharacter = line.first,
                let workingTreeStatus = FileStatus(rawValue: String(workingTreeStatusCharacter)) else { return }
                line.removeFirst()
                
                var filePath = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if filePath.contains(" -> ") {
                    filePath = String(filePath.split(separator: " -> ")[1])
                }
                
                files.append(File(filePath: filePath, indexStatus: indexStatus, workingTreeStatus: workingTreeStatus))
            }
        
        return files
    }
    
    // Example output:
    // On branch main
    // Your branch is ahead of 'origin/main' by 1 commit.
    // ... (Not relevant, first two lines are relevant)
    func parseGitStatusOutput(_ output: String) {
        let outputPerLine = output.split(separator: "\n")
        currentBranchSubject.send(String(outputPerLine[0].split(separator: " ")[2]))
        commitsComparedToUpstreamMessageSubject.send(String(outputPerLine[1]))
    }
}

// MARK: - Parsing git diff output -

private extension GitService {
    func parseGitDiffOutput(_ output: String) -> String {
        // TODO: Implement parsing
        return output
    }
}
