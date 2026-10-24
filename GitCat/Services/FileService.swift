//
//  FileService.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import Foundation
import OSLog

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
            Logger.files.error("Couldn't list contents of \(directory): \(error.localizedDescription)")
        }
        
        return files
    }
    
    func isGitRepository(at directory: String) -> Bool {
        getContents(of: directory).contains(".git")
    }
}
