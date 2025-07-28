//
//  ChangedFileListItemView.swift
//  GitCat
//
//  Created by Filip Čulig on 02.11.2023..
//

import SwiftUI

// MARK: - ChangedFileListItemView -
struct ChangedFileListItemView: View {
    @State private var viewModel: ChangedFileListItemViewModel
    
    init(viewModel: ChangedFileListItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(viewModel.file.indexStatus.statusSymbol)
            
            Text(viewModel.file.workingTreeStatus.statusSymbol)
            
            Text(viewModel.file.filePath)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
