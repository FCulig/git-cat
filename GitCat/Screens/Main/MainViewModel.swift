//
//  MainViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Combine
import SwiftUI

// MARK: - MainViewModel -
class MainViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
        
    let mainMenuViewModel: MainMenuViewModel
    let topBarViewModel: TopBarViewModel
    
    // MARK: - Initializer -
    
    init(mainMenuViewModel: MainMenuViewModel,
         topBarViewModel: TopBarViewModel) {
        self.mainMenuViewModel = mainMenuViewModel
        self.topBarViewModel = topBarViewModel
    }
}
