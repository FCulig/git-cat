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
        DirectorySelectionView(viewModel: viewModel.directorySelectionViewModel) {
            Text("Select workspace")
        }
    }
}
    
// MARK: - Workspace selected -

private extension FileListView {
    var changedFilesList: some View {
        ChangedFilesListView(viewModel: viewModel.changedFilesListViewModel)
    }
}
