//
//  RecentRepository.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Foundation

// MARK: - RecentRepository -
struct RecentRepository: Codable, Identifiable, Equatable {
    let path: String
    var branch: String
    var lastOpened: Date

    var id: String { path }

    var name: String {
        URL(fileURLWithPath: path).lastPathComponent
    }

    var displayPath: String {
        (path as NSString).abbreviatingWithTildeInPath
    }
}
