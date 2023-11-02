//
//  MainView.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

// MARK: - MainView -
struct MainView: View {
    @ObservedObject private var viewModel: MainViewModel
    
    // MARK: - Initializer -
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        HSplitView {
            ResizableView(width: $viewModel.fileListWidth, dividerLocation: .trailing) {
                FileListView(viewModel: viewModel.fileListViewModel)
            }
//            .frame(minWidth: 300)
//            .frame(width: viewModel.fileListWidth)
            
            ResizableView() {
                ChangesView(viewModel: viewModel.changesViewModel)
            }
//            .frame(minWidth: 300)
        }
    }
}

// MARK: - Preview -

//#Preview {
//    MainView()
//}
