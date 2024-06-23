//
//  DirectorySelectionView.swift
//  GitCat
//
//  Created by Filip Čulig on 23.06.2024..
//

import SwiftUI

struct DirectorySelectionView<Label: View>: View {
    @ObservedObject private var viewModel: DirectorySelectionViewModel
    @ViewBuilder private var label: Label
    
    init(viewModel: DirectorySelectionViewModel, label: () -> Label) {
        self.label = label()
        self.viewModel = viewModel
    }
    
    var body: some View {
        Button(action: viewModel.showOpenPanel) {
            label
        }
        .alert(isPresented: $viewModel.isShowingInvalidWorkspaceAlert) {
            Alert(title: Text("Invalid directory"),
                  message: Text("Selected directory is not a git repository"),
                  dismissButton: .default(Text("OK")))
        }
    }
}
