//
//  OpeningProgress.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Foundation

// MARK: - OpeningProgress -

/// Progress of opening a repository: which git refresh step is running and how far the loader has moved.
/// Each finished step moves the loader forward by an equal share. The fraction eases between values, so the loader
/// glides forward instead of jumping.
struct OpeningProgress {
    static let transitionDuration: TimeInterval = 0.35

    let repository: RecentRepository
    let startDate = Date.now

    /// Step that is currently running, `nil` once all of them finished.
    private(set) var step: GitRefreshStep? = GitRefreshStep.allCases.first

    private var startFraction = 0.0
    private var targetFraction = 0.0
    private var changeDate = Date.now

    var isDone: Bool { step == nil }

    var label: String { step?.title ?? "Done" }

    init(repository: RecentRepository) {
        self.repository = repository
    }

    func fraction(at date: Date) -> Double {
        let time = min(1, max(0, date.timeIntervalSince(changeDate) / Self.transitionDuration))
        let easedTime = 1 - pow(1 - time, 3)
        return startFraction + (targetFraction - startFraction) * easedTime
    }

    mutating func finish(_ finishedStep: GitRefreshStep) {
        let steps = GitRefreshStep.allCases
        guard let index = steps.firstIndex(of: finishedStep) else { return }

        startFraction = fraction(at: .now)
        targetFraction = Double(index + 1) / Double(steps.count)
        changeDate = .now
        step = index + 1 < steps.count ? steps[index + 1] : nil
    }
}
