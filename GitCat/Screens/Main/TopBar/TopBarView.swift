//
//  TopBarView.swift
//  GitCat
//
//  Created by Filip Čulig on 23.05.2024..
//

import SwiftUI

// MARK: - TopBarView -
struct TopBarView: View {
    @ObservedObject private var viewModel: TopBarViewModel
    
    init(viewModel: TopBarViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        HStack(spacing: 10){
            AppIcon.branch.image
                .resizable()
                .foregroundStyle(.white)
                .scaledToFit()
                .frame(width: 30)
            
            menu
            
            Spacer()
        }
        .padding(15)
    }
}

// MARK: - Menu -

private extension TopBarView {
    var menu: some View {
        Menu {
            menuItems
        } label: {
            menuLabel
        }
        .menuStyle(BorderlessButtonMenuStyle())
        .frame(width: 100)
    }
    
    var menuItems: some View {
        ForEach(viewModel.branches, id: \.self) { branchName in
            Button {
                viewModel.checkoutBranch(branchName)
            } label: {
                Label {
                    Text(branchName)
                } icon: {
                    if branchName == viewModel.currentBranch {
                        Image(systemName: "checkmark")
                    }
                }
                .labelStyle(.titleAndIcon)
            }
        }
    }
    
    var menuLabel: some View {
        Text(viewModel.currentBranch)
            .font(.title2)
            .fontWeight(.bold)
            .padding(4)
    }
}
