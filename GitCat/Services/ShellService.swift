//
//  ShellService.swift
//  GitCat
//
//  Created by Filip Čulig on 29.09.2023..
//

import Foundation

// MARK: - ShellService -
class ShellService {
    // TODO: Make global file for these user defaults keys
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
}

// MARK: - Public methods -

extension ShellService {
    func execute(_ command: String) -> String {
        guard let workingDirectory = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) else { return "" }
        
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
        
        // TODO: Do not force unwrap
        return String(data: data, encoding: .utf8)!
    }
}
