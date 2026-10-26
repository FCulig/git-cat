//
//  AppColor.swift
//  GitCat
//
//  Created by Filip Čulig on 05.05.2024..
//

import SwiftUI

enum AppColor { }

// MARK: - Surfaces -

extension AppColor {
    static let background = Color(.primaryBackground)
    static let secondaryBackground = Color(.secondaryBackground)
    static let buttonBackground = Color(.buttonBackground)
    static let checkboxBackground = Color(.checkboxBackground)
    static let checkboxBorder = Color(.checkboxBorder)
    static let line = Color(.hairline)
    static let windowLine = Color(.windowBorder)
    static let rowSelection = Color(.rowSelection)
    static let sidebarSelection = Color(.sidebarSelection)
    static let addedBackground = Color(.addedBackground)
    static let removedBackground = Color(.removedBackground)
}

// MARK: - Text -

extension AppColor {
    static let primaryText = Color(.primaryText)
    static let secondaryText = Color(.secondaryText)
    static let tertiaryText = Color(.tertiaryText)
}

// MARK: - Accents -

extension AppColor {
    static let accent = Color(.brand)
    static let accentHighlighted = Color(.brandHighlighted)
    static let added = Color(.added)
    static let removed = Color(.removed)
    static let modified = Color(.modified)
    static let addedText = Color(.addedText)
    static let removedText = Color(.removedText)
}
