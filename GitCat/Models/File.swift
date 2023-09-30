//
//  FileStatus.swift
//  GitCat
//
//  Created by Filip Čulig on 28.09.2023..
//

// MARK: - FileStatus -
enum FileStatus: String {
    case new = "N"
    case modified = "M"
    case deleted = "D"
}

// MARK: - File -
struct File: Hashable {
    let filePath: String
    let status: FileStatus
    let isStaged: Bool
    
    init(filePath: String, status: FileStatus, isStaged: Bool = false) {
        self.filePath = filePath
        self.status = status
        self.isStaged = isStaged
    }
}
