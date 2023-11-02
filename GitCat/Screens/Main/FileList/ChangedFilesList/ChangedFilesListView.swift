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
    
    // MARK: - No changes -
    
    var noChangesMessage: some View {
        Text("There are no changes")
    }
    
    // MARK: - Changes -
    
    var changedFilesList: some View {
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
