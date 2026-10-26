//
//  SidebarItem.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

// MARK: - SidebarItem -

/// Items of the sidebar's workspace section.
enum SidebarItem: CaseIterable, Identifiable {
    case changes
    case history
    case stashes

    var id: Self { self }

    var title: String {
        switch self {
        case .changes: "Changes"
        case .history: "History"
        case .stashes: "Stashes"
        }
    }

    /// History and stashes are listed, but can't be opened yet.
    var isAvailable: Bool {
        self == .changes
    }
}
