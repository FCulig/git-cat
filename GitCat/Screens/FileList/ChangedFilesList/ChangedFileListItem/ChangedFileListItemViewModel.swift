//
//  ChangedFileListItemViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 26.05.2024..
//

import Foundation

final class ChangedFileListItemViewModel: ObservableObject {
    let file: File
    
    init(file: File) {
        self.file = file
    }
}
