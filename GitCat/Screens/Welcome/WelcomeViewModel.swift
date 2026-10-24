//
//  WelcomeViewModel.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import AppKit
import Combine
import SwiftUI

// MARK: - WelcomeViewModel -
final class WelcomeViewModel: ObservableObject {
    // MARK: - Private properties -

    private let recentRepositoriesService: RecentRepositoriesService
    private let fileService: FileService
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Public properties -

    @Published private(set) var recents: [RecentRepository] = []
    @Published private(set) var autoOpenPath: String?
    @Published var selectedPath: String?
    @Published var isShowingInvalidRepositoryAlert = false

    /// Called when the user asks to open a repository.
    var onOpen: ((RecentRepository) -> Void)?

    var selectedRepository: RecentRepository? {
        recents.first { $0.path == selectedPath } ?? recents.first
    }

    var isAutoOpenEnabled: Bool {
        guard let selectedRepository else { return false }
        return autoOpenPath == selectedRepository.path
    }

    var heading: String {
        recents.isEmpty ? "Welcome to git cat" : "Welcome back"
    }

    var subheading: String {
        recents.isEmpty
            ? "Choose a Git repository on your Mac to get started."
            : "Pick a recent repository or choose another one on your Mac."
    }

    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    // MARK: - Initializer -

    init(recentRepositoriesService: RecentRepositoriesService,
         fileService: FileService) {
        self.recentRepositoriesService = recentRepositoriesService
        self.fileService = fileService

        autoOpenPath = recentRepositoriesService.autoOpenPath

        recentRepositoriesService.recents
            .sink { [weak self] in self?.recents = $0 }
            .store(in: &cancellables)

        selectedPath = recents.first?.path
    }
}

// MARK: - Public methods -

extension WelcomeViewModel {
    func chooseRepository() {
        let openPanel = NSOpenPanel()
        openPanel.message = "Choose a folder that contains a Git repository."
        openPanel.prompt = "Open"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false

        let handleResult = { [weak self, openPanel] (response: NSApplication.ModalResponse) in
            guard response == .OK, let url = openPanel.url else { return }
            self?.addRepository(at: url)
        }

        if let window = NSApp.keyWindow {
            openPanel.beginSheetModal(for: window, completionHandler: handleResult)
        } else {
            handleResult(openPanel.runModal())
        }
    }

    func handleDrop(of providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) }) else { return false }

        _ = provider.loadObject(ofClass: URL.self) { [weak self] url, _ in
            guard let url else { return }
            DispatchQueue.main.async { self?.addRepository(at: url) }
        }
        return true
    }

    func select(_ repository: RecentRepository) {
        selectedPath = repository.path
    }

    func open(_ repository: RecentRepository) {
        selectedPath = repository.path
        onOpen?(repository)
    }

    func openSelected() {
        guard let selectedRepository else { return }
        open(selectedRepository)
    }

    func setAutoOpen(_ isEnabled: Bool) {
        guard let selectedRepository else { return }

        autoOpenPath = isEnabled ? selectedRepository.path : nil
        recentRepositoriesService.autoOpenPath = autoOpenPath
    }
}

// MARK: - Private methods -

private extension WelcomeViewModel {
    func addRepository(at url: URL) {
        guard fileService.isGitRepository(at: url.path) else {
            isShowingInvalidRepositoryAlert = true
            return
        }

        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.42)) {
            let repository = recentRepositoriesService.add(path: url.path)
            selectedPath = repository.path
        }
    }
}
