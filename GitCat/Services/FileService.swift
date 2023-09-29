//
//  FileService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Foundation

// MARK: - FileService -
class FileService {
    
}

// MARK: - Public methods -

extension FileService {
    func getContents(of directory: String) -> [String] {
        let fm = FileManager.default
        var files: [String] = []
        
        do {
            files = try fm.contentsOfDirectory(atPath: directory)
        } catch {
            print(error)
        }
        
        return files
    }
}
