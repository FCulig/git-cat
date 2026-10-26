//
//  MainView.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

// MARK: - MainView -
struct MainView: View {
    static let minimumSize = CGSize(width: 1040, height: 640)
    /// Size of the window when the repository opens.
    static let defaultSize = CGSize(width: 1280, height: 800)
    
    @ObservedObject private var viewModel: MainViewModel
    
    // MARK: - Initializer -
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        HStack(spacing: 0) {
            SidebarView(viewModel: viewModel.sidebarViewModel)
            
            // History and stashes can't be selected yet.
            WorkingCopyView(viewModel: viewModel.workingCopyViewModel)
        }
        .background(AppColor.background)
        // The sidebar shares its top row with the window's traffic lights.
        .ignoresSafeArea()
    }
}
