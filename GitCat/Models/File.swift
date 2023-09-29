//
//  FileStatus.swift
//  GitCat
//
//  Created by Filip Čulig on 28.09.2023..
//

// MARK: - FileStatus -
enum FileStatus: String {
    case new = "new file"
    case modified
    case deleted
}

// MARK: - StageingStatus -
enum StageingStatus: String, Hashable {
    case staged
    case unstaged
    case untracked
}

// MARK: - File -
struct File: Hashable {
    let filePath: String
    let status: FileStatus
    let stageingStatus: StageingStatus
}
