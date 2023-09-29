//
//  GitService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Foundation

// MARK: - GitService -
class GitService {
    // TODO: Make global file for these user defaults keys
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
}

// MARK: - Public methods -

extension GitService {
    func getChangedFiles() -> [File] {
        guard let workingDirectory = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) else { return [] }
        
        // TODO: Move this to shell service
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", "git status"]
        task.launchPath = "/bin/zsh"
        task.standardInput = nil
        task.currentDirectoryPath = workingDirectory
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return parseGitStatusOutput(output)
    }
}

// MARK: - Parsing git status output -

private extension GitService {
    func parseGitStatusOutput(_ output: String) -> [File] {
        let stagedChangesSplitted = output.split(separator: "Changes to be committed:")
        var stagedChanges = stagedChangesSplitted[1]
        
        let unstagedChangesSplitted = stagedChanges.split(separator: "Changes not staged for commit:")
        var unstagedChanges = unstagedChangesSplitted[1]
        stagedChanges = unstagedChangesSplitted[0]
        
        let untrackedFilesSplitted = unstagedChanges.split(separator: "Untracked files:")
        unstagedChanges = untrackedFilesSplitted[0]

        let stagedFiles = parseStageingStatusSection(String(stagedChanges), stageingStatus: .staged)
        let unstagedFiles = parseStageingStatusSection(String(unstagedChanges), stageingStatus: .unstaged)
        let untrackedFiles = parseStageingStatusSection(String(untrackedFilesSplitted[1]), stageingStatus: .untracked)
        
        return stagedFiles + unstagedFiles + untrackedFiles
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
