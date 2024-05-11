//
//  ChangedFilesListView.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

// MARK: - ChangedFilesListView -
struct ChangedFilesListView: View {
    @ObservedObject private var viewModel: ChangedFilesListViewModel
    
    // MARK: - Initializer -
    
    init(viewModel: ChangedFilesListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        if viewModel.changedFiles.isEmpty {
            noChangesMessage
        } else {
            changedFilesList
        }
    }
}

// MARK: - No changes -

private extension ChangedFilesListView {
    var noChangesMessage: some View {
        Text("There are no changed files")
    }
}
    
// MARK: - Changed files -
    
private extension ChangedFilesListView {
    var changedFilesList: some View {
        VStack(spacing: 20) {
            changedFiles
            
            if viewModel.isCommitMessageTextFieldVisible {
                TextField(text: $viewModel.commitMessage, label: { Text("Enter your commit message") })
            }
            
            Button("Commit changes", action: {
                if viewModel.isCommitMessageTextFieldVisible {
                    viewModel.commitChanges()
                } else {
                    viewModel.isCommitMessageTextFieldVisible = true
                }
            })
            .disabled(viewModel.isCommitMessageTextFieldVisible ? viewModel.commitMessage.isEmpty : false)
        }
    }
    
    var changedFiles: some View {
        ScrollView {
            ForEach(viewModel.changedFiles, id: \.self) { changedFile in
                ChangedFileListItemView(viewModel: changedFile)
                    .onTapGesture {
                        viewModel.select(itemViewModel: changedFile)
                    }
            }
        }
    }
}

//#Preview {
//    ChangedFilesListView()
//}
