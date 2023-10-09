//
//  GitService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Foundation

// MARK: - GitService -
class GitService {
    private let shellService: ShellService
    
    init(shellService: ShellService) {
        self.shellService = shellService
    }
}

// MARK: - Public methods -

extension GitService {
    func getChangedFiles() -> [File] {
        let output = shellService.execute(GitCommands.status.rawValue)
        return parseGitStatusOutput(output)
    }
    
    func getChangesFor(file: File) -> String {
        let output = shellService.execute("\(GitCommands.diff.rawValue) \(file.filePath)")
        return parseGitDiffOutput(output)
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
    func parseGitStatusOutput(_ output: String) -> [File] {
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
}

// MARK: - Parsing git diff output -

private extension GitService {
    func parseGitDiffOutput(_ output: String) -> String {
        // TODO: Implement parsing
        return output
    }
}
