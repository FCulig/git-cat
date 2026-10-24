//
//  ShellService.swift
//  GitCat
//
//  Created by Filip Čulig on 29.09.2023..
//

import Foundation

// MARK: - ShellResult -
struct ShellResult {
    let output: String
    let errorOutput: String
    let exitCode: Int32

    var succeeded: Bool { exitCode == 0 }
}

// MARK: - ShellService -
class ShellService {
    // TODO: Make global file for these user defaults keys
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
}

// MARK: - Public methods -

extension ShellService {
    /// Executes the command in `directory`, or in the selected workspace when no directory is given, and returns its
    /// standard output. Use `run` when failures matter.
    @discardableResult func execute(_ command: String, in directory: String? = nil) -> String {
        run(command, in: directory).output
    }

    /// Executes the command in `directory`, or in the selected workspace when no directory is given.
    func run(_ command: String, in directory: String? = nil) -> ShellResult {
        guard let workingDirectory = directory ?? UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) else {
            return ShellResult(output: "", errorOutput: "No workspace selected", exitCode: -1)
        }

        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        task.standardInput = nil
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)

        do {
            try task.run()
        } catch {
            return ShellResult(output: "", errorOutput: error.localizedDescription, exitCode: -1)
        }

        // Both pipes are drained at the same time, otherwise a command that fills one of them blocks forever.
        var errorData = Data()
        let errorReading = DispatchGroup()
        errorReading.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            errorReading.leave()
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        errorReading.wait()
        task.waitUntilExit()

        return ShellResult(output: String(decoding: outputData, as: UTF8.self),
                           errorOutput: String(decoding: errorData, as: UTF8.self),
                           exitCode: task.terminationStatus)
    }
}
