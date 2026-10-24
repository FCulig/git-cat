//
//  CatIdleAnimator.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import AppKit
import Combine

// MARK: - CatIdleClip -

/// Small animations the logo cat plays while the user is idle. They run in order and loop.
/// Each clip is a marker with the same name in `cat-idle.json`.
enum CatIdleClip: String, CaseIterable {
    case blink
    case glance
    case knead
    case doubleBlink
    case tilt
    case peek

    var markerName: String { rawValue }

    var duration: TimeInterval {
        switch self {
        case .blink: 0.2
        case .glance: 2.45
        case .knead: 1.64
        case .doubleBlink: 0.52
        case .tilt: 1.7
        case .peek: 1.8
        }
    }
}

// MARK: - CatIdleAnimator -

/// Plays `CatIdleClip`s after the user has been inactive for `idleDelay`. Any click or key press restarts the wait.
final class CatIdleAnimator: ObservableObject {
    // MARK: - Public properties -

    /// Clip that is currently playing, `nil` while the cat rests.
    @Published private(set) var clip: CatIdleClip?

    var isPaused = false {
        didSet { if isPaused { stop() } else { rearm() } }
    }

    // MARK: - Private properties -

    private let idleDelay: TimeInterval
    private var nextClipIndex = 0
    private var task: Task<Void, Never>?
    private var eventMonitor: Any?

    // MARK: - Initializer -

    init(idleDelay: TimeInterval = 3) {
        self.idleDelay = idleDelay
    }

    deinit {
        task?.cancel()
        if let eventMonitor { NSEvent.removeMonitor(eventMonitor) }
    }
}

// MARK: - Public methods -

extension CatIdleAnimator {
    func start() {
        if eventMonitor == nil {
            eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown, .keyDown]) { [weak self] event in
                self?.rearm()
                return event
            }
        }
        rearm()
    }

    func stop() {
        task?.cancel()
        task = nil
        clip = nil
    }
}

// MARK: - Private methods -

private extension CatIdleAnimator {
    func rearm() {
        stop()
        guard !isPaused else { return }

        task = Task { @MainActor [weak self, idleDelay] in
            try? await Task.sleep(for: .seconds(idleDelay))

            while !Task.isCancelled, let clip = self?.playNextClip() {
                try? await Task.sleep(for: .seconds(clip.duration))
                guard !Task.isCancelled else { return }

                self?.clip = nil
                try? await Task.sleep(for: .seconds(2.2 + .random(in: 0...1.6)))
            }
        }
    }

    func playNextClip() -> CatIdleClip {
        let clip = CatIdleClip.allCases[nextClipIndex % CatIdleClip.allCases.count]
        nextClipIndex += 1
        self.clip = clip
        return clip
    }
}
