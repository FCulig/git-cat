//
//  ChangedFileListItemView.swift
//  GitCat
//
//  Created by Filip Čulig on 02.11.2023..
//

import SwiftUI

// MARK: - ChangedFileListItemView -
struct ChangedFileListItemView: View {
    @ObservedObject private var viewModel: ChangedFileListItemViewModel
    
    init(viewModel: ChangedFileListItemViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Text(viewModel.file.filePath)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(viewModel.isSelected ? .gray : .clear)
    }
}

//#Preview {
//    ChangedFileListItemView()
//}
