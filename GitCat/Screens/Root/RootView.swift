//
//  RootView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - RootView -
struct RootView: View {
    @ObservedObject private var viewModel: RootViewModel

    // MARK: - Initializer -

    init(viewModel: RootViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body -

    var body: some View {
        ZStack {
            switch viewModel.screen {
            case .welcome:
                WelcomeView(viewModel: viewModel.welcomeViewModel,
                            isActive: viewModel.openingRepository == nil)
                .transition(.opacity)
            case .main:
                MainView(viewModel: viewModel.mainViewModel)
                    .frame(minWidth: WelcomeView.size.width, minHeight: WelcomeView.size.height)
                    .transition(.opacity)
            }

            if let repository = viewModel.openingRepository {
                OpeningRepositoryView(repository: repository, onFinish: viewModel.openingDidFinish)
                    .id(repository.id)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        // Without this the window reserves room for the title bar above the fixed size welcome screen.
        .ignoresSafeArea(edges: viewModel.screen == .welcome ? .all : [])
        .background(WindowConfigurator(fixedSize: viewModel.screen == .welcome ? WelcomeView.size : nil))
    }
}
