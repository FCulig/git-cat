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
        }
    }
}
