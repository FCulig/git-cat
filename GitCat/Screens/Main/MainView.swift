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
    }
}
