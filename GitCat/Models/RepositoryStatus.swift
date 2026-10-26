//
//  RepositoryStatus.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Foundation

// MARK: - UpstreamStatus -

/// How the current branch compares to the branch it tracks.
struct UpstreamStatus: Equatable {
    let name: String
    let ahead: Int
    let behind: Int

    var remote: String {
        String(name.prefix(while: { $0 != "/" }))
    }
}

// MARK: - CommitSummary -
struct CommitSummary: Equatable {
    let hash: String
    let message: String
}

// MARK: - HistorySummary -
struct HistorySummary: Equatable {
    let commitCount: Int
    /// `nil` before the first commit.
    let lastCommit: CommitSummary?
}
