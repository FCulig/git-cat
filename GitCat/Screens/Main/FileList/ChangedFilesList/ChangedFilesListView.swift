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
    @FocusState private var isTextFieldFocused: Bool
    
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
            comparedToUpstreamBanner
            changedFiles
            commitSection
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

// MARK: - Status compared to origin -

private extension ChangedFilesListView {
    var comparedToUpstreamBanner: some View {
        Text(viewModel.upstreamCommitDifferece)
            .frame(maxWidth: .infinity)
            .padding(16)
            .border(.yellow, width: 1)
            .background(.yellow.opacity(0.1))
    }
}

// MARK: - Commit section -

private extension ChangedFilesListView {
    @ViewBuilder var commitSection: some View {
        VStack(spacing: 8) {
            TextField(text: $viewModel.commitMessage, label: { Text("Enter your commit message") })
                .focused($isTextFieldFocused, equals: true)
                .onAppear {
                    // Remove default focus from the text field
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                        NSApp.keyWindow?.makeFirstResponder(nil)
                    })
                }
            
            HStack(spacing: 8) {
                Button("Commit changes", action: {
                    viewModel.commitChanges(shouldPushChanges: false)
                    isTextFieldFocused = false
                })
                .disabled(viewModel.commitMessage.isEmpty)
                
                Button("Commit and push changes", action: {
                    viewModel.commitChanges(shouldPushChanges: true)
                    isTextFieldFocused = false
                })
                .disabled(viewModel.commitMessage.isEmpty)
            }
        }
    }
}

//#Preview {
//    ChangedFilesListView()
//}
