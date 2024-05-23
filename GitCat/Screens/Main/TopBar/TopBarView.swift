//
//  TopBarView.swift
//  GitCat
//
//  Created by Filip Čulig on 23.05.2024..
//

import SwiftUI

struct TopBarView: View {
    @ObservedObject private var viewModel: TopBarViewModel
    
    init(viewModel: TopBarViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(spacing: 6) {
            AppIcon.branch.image
                .resizable()
                .foregroundStyle(.white)
                .scaledToFit()
                .frame(width: 30)
            
            Text(viewModel.currentBranch)
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding(12)
    }
}
