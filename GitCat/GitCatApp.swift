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
        WindowGroup {
            MainView(viewModel: MainViewModel(changesViewModel: ChangesViewModel(),
                                              fileListViewModel: FileListViewModel(changedFilesListViewModel: ChangedFilesListViewModel(gitService: GitService()),
                                                                                   fileService: FileService())))
        }
    }
}
