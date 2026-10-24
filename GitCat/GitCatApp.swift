//
//  GitCatApp.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

@main
struct GitCatApp: App {
    @StateObject private var rootViewModel = RootViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView(viewModel: rootViewModel)
            // Disabled while in development to allow easier debugging. Constant file refreshes make it hard to track
            // what is going on.
            //
            // Refresh file status each time focus gets switched to the app
            //.onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            //    DispatchQueue.main.async {
            //        gitService.refreshChangedFiles()
            //    }
            //}
        }
        // Welcome screen draws under the title bar. Window size and title bar are adjusted per screen by
        // `WindowConfigurator`.
        .windowStyle(.hiddenTitleBar)
    }
}
