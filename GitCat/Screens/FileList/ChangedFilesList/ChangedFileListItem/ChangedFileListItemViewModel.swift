//
//  ChangedFileListItemViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 26.05.2024..
//

import Foundation

struct ChangedFileListItemViewModel: Hashable, Identifiable {
    let id = UUID()
    let file: File
    
    init(file: File) {
        self.file = file
    }
}

extension ChangedFileListItemViewModel: Equatable {
    static func == (lhs: ChangedFileListItemViewModel, rhs: ChangedFileListItemViewModel) -> Bool {
        rhs.file == lhs.file &&
        rhs.id == lhs.id
    }
}
