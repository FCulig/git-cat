//
//  GitCatApp.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

@main
struct GitCatApp: App {
    @State private var didAppear = false
    
    var body: some Scene {
        let shellService = ShellService()
        let fileService = FileService()
        let gitService = GitService(shellService: shellService)
        let directorySelectionViewModel = DirectorySelectionViewModel(fileService: fileService,
                                                                      gitService: gitService)
        let fileListViewModel = FileListViewModel(directorySelectionViewModel: directorySelectionViewModel,
                                                  changedFilesListViewModel: ChangedFilesListViewModel(gitService: gitService))
        
        return WindowGroup {
            MainView(viewModel: MainViewModel(directorySelectionViewModel: directorySelectionViewModel,
                                              fileListViewModel: fileListViewModel,
                                              gitService: gitService))
            .onAppear {
                guard !didAppear else { return }
                
                DispatchQueue.main.async {
                    gitService.refreshChangedFiles()
                    didAppear = true
                }
            }
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
    }
}
