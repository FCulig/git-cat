//
//  Logger+GitCat.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Foundation
import OSLog

// MARK: - Loggers -

/// One logger per area of the app, so Console.app can filter by category. Interpolated values are private by default
/// and only show up in full while a debugger is attached.
extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.filip.culig.GitCat"

    static let shell = Logger(subsystem: subsystem, category: "Shell")
    static let git = Logger(subsystem: subsystem, category: "Git")
    static let files = Logger(subsystem: subsystem, category: "Files")
    static let recents = Logger(subsystem: subsystem, category: "Recents")
    static let navigation = Logger(subsystem: subsystem, category: "Navigation")
}
