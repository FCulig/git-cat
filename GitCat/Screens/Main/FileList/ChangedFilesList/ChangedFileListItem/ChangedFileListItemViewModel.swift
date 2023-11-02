//
//  ChangedFileListItemViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 02.11.2023..
//

import Combine
import Foundation

// MARK: - ChangedFileListItemViewModel -
final class ChangedFileListItemViewModel: ObservableObject {
    // MARK: - Private propertoes -
    
    private let id = UUID()
    
    // MARK: - Public properties -
    
    @Published var isSelected = false
    
    let file: File
    
    // MARK: - Initializer -
    
    init(file: File) {
        self.file = file
    }
}

// MARK: - Conformance to Equatable -

extension ChangedFileListItemViewModel: Equatable, Hashable {
    static func == (lhs: ChangedFileListItemViewModel, rhs: ChangedFileListItemViewModel) -> Bool {
        lhs.file == rhs.file
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
