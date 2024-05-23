//
//  GitCatApp.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

@main
struct GitCatApp: App {
    var body: some Scene {
        let shellService = ShellService()
        let gitService = GitService(shellService: shellService)
        
        return WindowGroup {
            MainView(viewModel: MainViewModel(changesViewModel: ChangesViewModel(gitService: gitService),
                                              fileListViewModel: FileListViewModel(changedFilesListViewModel: ChangedFilesListViewModel(gitService: gitService),
                                                                                   fileService: FileService())))
            // Refresh file status each time focus gets switched to the app
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                DispatchQueue.main.async {
                    gitService.refreshChangedFiles()
                }
            }
        }
    }
}
