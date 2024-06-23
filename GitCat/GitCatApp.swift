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
        let fileListViewModel = FileListViewModel(changedFilesListViewModel: ChangedFilesListViewModel(gitService: gitService),
                                                  fileService: FileService())
        
        return WindowGroup {
            MainView(viewModel: MainViewModel(mainMenuViewModel: MainMenuViewModel(fileListViewModel: fileListViewModel),
                                              topBarViewModel: TopBarViewModel(gitService: gitService)))
            .onAppear {
                DispatchQueue.main.async {
                    gitService.refreshChangedFiles()
                }
            }
            // Refresh file status each time focus gets switched to the app
            .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
                DispatchQueue.main.async {
                    gitService.refreshChangedFiles()
                }
            }
        }
    }
}
