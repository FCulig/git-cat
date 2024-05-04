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
    
    var statusSymbol: String {
        switch self {
        case .new:
            "🇦"
        case .modified:
            "🇷"
        case .deleted:
            "🇩"
        case .renamed:
            "🇷"
        case .unmodified:
            "     "
        }
    }
}

// MARK: - File -
struct File: Hashable {
    let filePath: String
    /// Status of the file in the stageing area.
    let indexStatus: FileStatus
    /// Status of the file in the working directory. (Not staged area)
    let workingTreeStatus: FileStatus
}

// MARK: - isStaged -

extension File {
    /// Returns if file is staged. File is stage only if working tree status is `unmodified`.
    var isStaged: Bool {
        workingTreeStatus == .unmodified
    }
}
