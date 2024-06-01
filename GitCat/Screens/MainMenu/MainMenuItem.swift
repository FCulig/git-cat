//
//  MainMenuItems.swift
//  GitCat
//
//  Created by Filip Čulig on 25.05.2024..
//

enum MainMenuItem: Int, CaseIterable, Identifiable, Hashable, Codable, Equatable {
    case workingDirectory
    case commits
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .workingDirectory:
            "Working directory"
        case .commits:
            "Commits"
        }
    }
}
