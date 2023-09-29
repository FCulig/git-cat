//
//  ChangesView.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import SwiftUI

// MARK: - ChangesView -
struct ChangesView: View {
    
    @ObservedObject private var viewModel: ChangesViewModel
    
    // MARK: - Initializer -
    
    init(viewModel: ChangesViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body -
    
    var body: some View {
        Text("Changes")
    }
}

//#Preview {
//    ChangesView()
//}
