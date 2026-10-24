//
//  RecentRepositoriesService.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Combine
import Foundation
import OSLog

// MARK: - RecentRepositoriesService -
final class RecentRepositoriesService {
    // MARK: - Private properties -

    private static let recentsUserDefaultsKey = "RecentRepositories"
    private static let autoOpenPathUserDefaultsKey = "AutoOpenRepositoryPath"
    private static let maximumNumberOfRecents = 10

    private let shellService: ShellService
    private let fileService: FileService
    private let recentsSubject: CurrentValueSubject<[RecentRepository], Never>

    // MARK: - Public properties -

    var recents: AnyPublisher<[RecentRepository], Never> {
        recentsSubject.eraseToAnyPublisher()
    }

    var currentRecents: [RecentRepository] {
        recentsSubject.value
    }

    /// Path of the repository that should be opened directly at launch, skipping the welcome screen.
    var autoOpenPath: String? {
        get { UserDefaults.standard.string(forKey: Self.autoOpenPathUserDefaultsKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: Self.autoOpenPathUserDefaultsKey) }
    }

    // MARK: - Initializer -

    init(shellService: ShellService, fileService: FileService) {
        self.shellService = shellService
        self.fileService = fileService
        self.recentsSubject = .init(Self.loadRecents())
    }
}

// MARK: - Public methods -

extension RecentRepositoriesService {
    /// Adds the repository to the top of the recents list, or moves it there if it is already present.
    @discardableResult func add(path: String) -> RecentRepository {
        let path = Self.normalize(path)
        let repository = RecentRepository(path: path, branch: currentBranch(at: path), lastOpened: .now)

        var recents = recentsSubject.value.filter { $0.path != path }
        recents.insert(repository, at: 0)
        save(Array(recents.prefix(Self.maximumNumberOfRecents)))

        return repository
    }

    /// Drops repositories that no longer exist on disk and refreshes the checked out branch of the rest.
    func refresh() {
        let recents = recentsSubject.value
            .filter { fileService.isGitRepository(at: $0.path) }
            .map {
                var repository = $0
                repository.branch = currentBranch(at: $0.path)
                return repository
            }

        if let autoOpenPath, !recents.contains(where: { $0.path == autoOpenPath }) {
            self.autoOpenPath = nil
        }

        save(recents)
    }
}

// MARK: - Private methods -

private extension RecentRepositoriesService {
    static func normalize(_ path: String) -> String {
        URL(fileURLWithPath: path).standardizedFileURL.path
    }

    static func loadRecents() -> [RecentRepository] {
        guard let data = UserDefaults.standard.data(forKey: recentsUserDefaultsKey) else { return [] }
        do {
            return try JSONDecoder().decode([RecentRepository].self, from: data)
        } catch {
            Logger.recents.error("Couldn't decode recent repositories: \(error.localizedDescription)")
            return []
        }
    }

    func save(_ recents: [RecentRepository]) {
        do {
            let data = try JSONEncoder().encode(recents)
            UserDefaults.standard.setValue(data, forKey: Self.recentsUserDefaultsKey)
        } catch {
            Logger.recents.error("Couldn't encode recent repositories: \(error.localizedDescription)")
        }
        recentsSubject.send(recents)
    }

    func currentBranch(at path: String) -> String {
        shellService.execute(GitCommands.currentBranch.rawValue, in: path)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
