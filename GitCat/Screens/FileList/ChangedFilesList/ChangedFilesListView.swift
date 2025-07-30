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
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
    }
    
    var changedFiles: some View {
        List(selection: $viewModel.selectedFile) {
            ForEach(viewModel.changedFiles) { changedFile in
                NavigationLink(value: changedFile) {
                    ChangedFileListItemView(viewModel: changedFile)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Status compared to origin - 

private extension ChangedFilesListView {
    @ViewBuilder var comparedToUpstreamBanner: some View {
        if let upstreamCommitDifferenceMessage = viewModel.upstreamCommitDifferenceMessage {
            HStack(spacing: 0) {
                Spacer()
                
                Text(upstreamCommitDifferenceMessage)
                    .padding(.trailing, 16)
                
                Button(action: viewModel.pushChanges) {
                    Text("Push changes")
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .border(.yellow, width: 1)
            .background(.yellow.opacity(0.1))
        }
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
