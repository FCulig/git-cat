//
//  MainMenuViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 25.05.2024..
//

import Combine

// MARK: - MainMenuViewModel
final class MainMenuViewModel: ObservableObject {
    @Published var selectedItem: MainMenuItem = .workingDirectory
}
