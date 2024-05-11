//
//  FileListView.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

// MARK: - FileListView -
struct FileListView: View {
    @ObservedObject private var viewModel: FileListViewModel
    
    // MARK: - Initializer -
    
    init(viewModel: FileListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        if viewModel.isWorkspaceSelected {
            changedFilesList
        } else {
            selectWorkspaceButton
        }
    }
}
    
// MARK: - Workspace not selected -

private extension FileListView {
    var selectWorkspaceButton: some View {
        Button("Select workspace") {
            viewModel.showOpenPanel()
        }
        .alert(isPresented: $viewModel.isShowingInvalidWorkspaceAlert) {
            Alert(title: Text("Invalid directory"),
                  message: Text("Selected directory is not a git repository"),
                  dismissButton: .default(Text("OK")))
        }
    }
}
    
// MARK: - Workspace selected -

private extension FileListView {
    var changedFilesList: some View {
        ChangedFilesListView(viewModel: viewModel.changedFilesListViewModel)
    }
}

//#Preview {
//    FileListView()
//}
