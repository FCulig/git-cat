//
//  FileStatus.swift
//  GitCat
//
//  Created by Filip Čulig on 28.09.2023..
//

// MARK: - FileStatus -
enum FileStatus: String {
    case new = "A"
    case modified = "M"
    case deleted = "D"
    case renamed = "R"
    case unmodified = " "
}

// MARK: - File -
struct File: Hashable {
    let filePath: String
    /// Status of the file in the stageing area.
    let indexStatus: FileStatus
    /// Status of the file in the working directory. (Not staged area)
    let workingTreeStatus: FileStatus
}
