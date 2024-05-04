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
            // For now whole file is being staged.
            // TODO: Implement staging of each chunk.
            stageControlButtons
            
            ForEach(viewModel.changes) { changeChunk in
                makeChangeChunk(for: changeChunk)
            }
        }
    }
}

// MARK: - Stage/Unstage buttons -

private extension ChangesView {
    var stageControlButtons: some View {
        HStack(spacing: 20) {
            Spacer()
            
            Button(action: viewModel.stageFile, label: {
                Text("Stage file")
            })
            .disabled(viewModel.isFileStaged)
            
            Button(action: viewModel.unstageFile, label: {
                Text("Unstage file")
            })
            .disabled(!viewModel.isFileStaged)
        }
    }
}


// MARK: - Changed chunk -

private extension ChangesView {
    func makeChangeChunk(for changeChunk: Change) -> some View {
        ForEach(changeChunk.changes) { change in
            Text(change.changes)
                .background(changeBackground(for: change.changes.first).opacity(0.4))
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
