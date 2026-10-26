//
//  ChangedFile.swift
//  GitCat
//
//  Created by Filip Čulig on 28.09.2023..
//

import Foundation

// MARK: - FileStatus -

/// One column of `git status --porcelain` output.
enum FileStatus: String {
    case new = "A"
    case modified = "M"
    case deleted = "D"
    case renamed = "R"
    case copied = "C"
    case typeChanged = "T"
    case unmerged = "U"
    case untracked = "?"
    case unmodified = " "

    /// Letter shown in the file list. Untracked files are new files as far as the user is concerned.
    var letter: String {
        self == .untracked ? FileStatus.new.rawValue : rawValue
    }

    var title: String {
        switch self {
        case .new: "Added"
        case .modified: "Modified"
        case .deleted: "Deleted"
        case .renamed: "Renamed"
        case .copied: "Copied"
        case .typeChanged: "Type Changed"
        case .unmerged: "Conflicted"
        case .untracked: "Untracked"
        case .unmodified: "Unmodified"
        }
    }
}

// MARK: - ChangedFile -

/// A file with changes on one side of the index. A file that has both staged and unstaged changes shows up twice,
/// once with `isStaged` set and once without.
struct ChangedFile: Hashable, Identifiable {
    /// Path relative to the repository root.
    let path: String
    let status: FileStatus
    let isStaged: Bool
    /// Path the file had before it was renamed or copied.
    var originalPath: String? = nil
    /// `nil` for binary files.
    var additions: Int? = nil
    var deletions: Int? = nil

    var id: String { "\(isStaged ? "staged" : "unstaged")/\(path)" }

    var name: String {
        (path as NSString).lastPathComponent
    }

    /// Folder of the file, `nil` when it's in the repository root.
    var directory: String? {
        let directory = (path as NSString).deletingLastPathComponent
        return directory.isEmpty ? nil : directory
    }
}
