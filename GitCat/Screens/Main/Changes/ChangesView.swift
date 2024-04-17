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
        VStack(spacing: 0) {
            ForEach(viewModel.changes) { changeChunk in
                makeChangeChunk(for: changeChunk)
            }
        }
    }
}

// MARK: - Changed chunk -

private extension ChangesView {
    func makeChangeChunk(for changeChunk: Change) -> some View {
        ForEach(changeChunk.change.split(separator: "\n"), id: \.self) { changeLine in
            Text(changeLine)
                .background(changeBackground(for: changeLine.first).opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


// MARK: - Changed line background -

private extension ChangesView {
    @ViewBuilder func changeBackground(for firstCharacther: Character?) -> some View {
        if firstCharacther == "-" {
            Color.red
        } else if firstCharacther == "+" {
            Color.green
        }
    }
}

//#Preview {
//    ChangesView()
//}
