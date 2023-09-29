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
        let output = shellService.execute("git status")
        return parseGitStatusOutput(output)
    }
}

// MARK: - Parsing git status output -

private extension GitService {
    func parseGitStatusOutput(_ output: String) -> [File] {
        var changedFiles: [File] = []
        let stagedChangesSplitted = output.split(separator: "Changes to be committed:")
        var stagedChanges = stagedChangesSplitted[1]
        
        let unstagedChangesSplitted = stagedChanges.split(separator: "Changes not staged for commit:")
        var unstagedChanges = unstagedChangesSplitted[1]
        stagedChanges = unstagedChangesSplitted[0]
        
        let untrackedFilesSplitted = unstagedChanges.split(separator: "Untracked files:")
        unstagedChanges = untrackedFilesSplitted[0]

        let stagedFiles = parseStageingStatusSection(String(stagedChanges), stageingStatus: .staged)
        let unstagedFiles = parseStageingStatusSection(String(unstagedChanges), stageingStatus: .unstaged)
        
        changedFiles += stagedFiles
        changedFiles += unstagedFiles
        
        if untrackedFilesSplitted.count == 2 {
            changedFiles += parseStageingStatusSection(String(untrackedFilesSplitted[1]), stageingStatus: .untracked)
        }
        
        return changedFiles
    }
    
    func parseStageingStatusSection(_ output: String, stageingStatus: StageingStatus) -> [File] {
        var splittedByLines = output.split(separator: "\n")
            
        // Remove line starting with (use "git...
        splittedByLines.removeFirst()
        
        // Staged files section has two (use "git... lines
        if stageingStatus == .unstaged {
            splittedByLines.removeFirst()
        }
        
        let linesWithNoWhitespaces = splittedByLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Using .forEach beacuse there was trouble unwraping touple in compact map
        var changedFiles: [File] = []
        linesWithNoWhitespaces.forEach {
            guard let file = stageingStatus == .untracked ? parseUntrackedLine($0) : parseTrackedLine($0, isStaged: true) else { return }
            changedFiles.append(file)
        }
        
        return changedFiles
    }
    
    func parseUntrackedLine(_ line: String) -> File {
        File(filePath: line, status: .new, stageingStatus: .untracked)
    }
    
    func parseTrackedLine(_ line: String, isStaged: Bool) -> File? {
        let splittedLine = line.split(separator: ":")
        let filePath = splittedLine[1].trimmingCharacters(in: .whitespacesAndNewlines)
        guard let fileStatus = FileStatus(rawValue: String(splittedLine[0])) else { return nil }
        
        return File(filePath: filePath, status: fileStatus, stageingStatus: isStaged ? .staged : .unstaged)
    }
}
