//
//  MainMenuView.swift
//  GitCat
//
//  Created by Filip Čulig on 25.05.2024..
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var viewModel: MainMenuViewModel
    
    init(viewModel: MainMenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(selection: $viewModel.selectedItem) {
            Text(MainMenuItem.workingDirectory.title)
                .tag(MainMenuItem.workingDirectory)
            
            Text(MainMenuItem.commits.title)
                .tag(MainMenuItem.commits)
        }
    }
}
