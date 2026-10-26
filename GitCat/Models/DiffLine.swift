//
//  DiffLine.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Foundation

// MARK: - DiffLine -

/// One line of a unified diff.
struct DiffLine: Identifiable, Equatable {
    enum Kind {
        /// `@@ -14,9 +14,13 @@` line that starts a hunk.
        case hunk
        case context
        case added
        case removed
    }

    let id: Int
    let kind: Kind
    let text: String
    /// Line number in the old version, `nil` for added lines and hunk headers.
    let oldNumber: Int?
    /// Line number in the new version, `nil` for removed lines and hunk headers.
    let newNumber: Int?
}
