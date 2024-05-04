//
//  Change.swift
//  GitCat
//
//  Created by Filip Čulig on 03.11.2023..
//

import Foundation

// MARK: - Change -
struct Change: Identifiable {
    let id = UUID()
    let changes: [ChangeChunk]
    
    init(changeChunk: String) {
        changes = changeChunk.split(separator: "\n").map(ChangeChunk.init)
    }
}

// MARK: - Change chunk -
struct ChangeChunk: Identifiable {
    let id = UUID()
    let changes: Substring
}
