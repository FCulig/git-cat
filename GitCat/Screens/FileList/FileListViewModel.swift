//
//  FileListViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 27.09.2023..
//

import AppKit
import Combine
import Foundation

// MARK: - FileListViewModel -
class FileListViewModel: ObservableObject {
    // MARK: - Private properties -
    
    private static let workspacePathUserDefaultsKey = "WorkspacePath"
    private let fileService: FileService
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public properties -
    
    @Published var isWorkspaceSelected: Bool
    @Published var isShowingInvalidWorkspaceAlert = false
    @Published var selectedFile: File?
    
    let changedFilesListViewModel: ChangedFilesListViewModel
    
    // MARK: - Initializer -
    
    init(changedFilesListViewModel: ChangedFilesListViewModel,
         fileService: FileService) {
        self.changedFilesListViewModel = changedFilesListViewModel
        self.fileService = fileService
        
        isWorkspaceSelected = UserDefaults.standard.string(forKey: Self.workspacePathUserDefaultsKey) != nil
        
        subscribeFileSelection()
    }
}

// MARK: - Public methods -

extension FileListViewModel {
    func showOpenPanel() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Select your workspace"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        guard openPanel.runModal() == .OK,
              let url = openPanel.url?.absoluteString.replacingOccurrences(of: "file:///", with: ""),
              isValid(directory: url) else {
            isShowingInvalidWorkspaceAlert = true
            return
        }
        
        UserDefaults.standard.setValue(url, forKey: Self.workspacePathUserDefaultsKey)
        isWorkspaceSelected = true
    }
}

// MARK: - Private methods -

private extension FileListViewModel {
    func isValid(directory url: String) -> Bool {
        let contents = fileService.getContents(of: url)
        return contents.contains(".git")
    }
    
    func subscribeFileSelection() {
        changedFilesListViewModel.$selectedFile
            .sink { [weak self] in self?.selectedFile = $0 }
            .store(in: &cancellables)
    }
}
