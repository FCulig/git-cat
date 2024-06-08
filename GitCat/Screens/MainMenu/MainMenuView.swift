//
//  MainMenuView.swift
//  GitCat
//
//  Created by Filip Čulig on 25.05.2024..
//

import SwiftUI

struct MainMenuView: View {
    @ObservedObject private var viewModel: MainMenuViewModel
    @State private var selectedItem: MainMenuItem? = .workingDirectory
    
    init(viewModel: MainMenuViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List(selection: $selectedItem) {
            NavigationLink(tag: MainMenuItem.workingDirectory, selection: $selectedItem) {
                FileListView(viewModel: viewModel.fileListViewModel)
            } label: {
                Text(MainMenuItem.workingDirectory.title)
            }
            
            NavigationLink {
                Text("One nice and sunny day you will see commits here.")
            } label: {
                Text(MainMenuItem.commits.title)
            }
        }
    }
}
