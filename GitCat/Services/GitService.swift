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
        let output = shellService.execute("git status --short")
        return parseGitStatusOutput(output)
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
        output.split(separator: "\n")
            .map { ($0.split(separator: " "), $0.first != " ") }
            .map { (FileStatus(rawValue: String($0.0[0])), String($0.0[1]), $0.1) }
            .map { File(filePath: $0.1, status: $0.0 ?? .new, isStaged: $0.2) }
    }
}
