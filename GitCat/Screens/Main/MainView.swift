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
        NavigationSplitView {
            MainMenuView(viewModel: viewModel.mainMenuViewModel)
        } content: {
            Text("Please select main menu item")
        } detail: {
            Text("Please select file from changed file list")
        }
        .navigationTitle("")
        .toolbar { toolbarItem }
    }
}

// MARK: - Toolbar item

private extension MainView {
    var toolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            HStack(spacing: 3) {
                Text(viewModel.repoName)
                    .font(.title2.weight(.bold))
                
                DirectorySelectionView(viewModel: viewModel.directorySelectionViewModel) {
                    Image(systemName: "folder")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .padding(.top, 3)
                }
            }
            .padding(.leading, 10)
        }
    }
}
