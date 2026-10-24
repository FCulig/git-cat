//
//  OpeningRepositoryView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - OpeningRepositoryView -

/// Full window overlay shown while a repository is being opened.
struct OpeningRepositoryView: View {
    // MARK: - Private properties -

    // Must match DURATION, LINGER and progress() in Design/Lottie/generate_cat_loader.py, which bakes the loader.
    private static let duration: TimeInterval = 2.6
    private static let lingerAfterDone: TimeInterval = 0.45
    private static let steps: [(until: Double, label: String)] = [
        (0.2, "Reading index"),
        (0.55, "Scanning working tree"),
        (0.9, "Loading history"),
        (1, "Almost there"),
    ]

    @State private var startDate = Date.now

    private let repository: RecentRepository
    private let onFinish: () -> Void

    // MARK: - Initializer -

    init(repository: RecentRepository, onFinish: @escaping () -> Void) {
        self.repository = repository
        self.onFinish = onFinish
    }

    // MARK: - Body -

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            let progress = Self.progress(at: elapsed)

            VStack(spacing: 6) {
                CatLoaderView(time: elapsed)
                    .frame(width: 440)

                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 6) {
                        Text("Opening \(repository.name)")
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColor.primaryText)
                        Text(Self.stepLabel(for: progress))
                            .foregroundStyle(AppColor.secondaryText)
                    }
                    .lineLimit(1)

                    Spacer()

                    Text("\(Int((progress * 100).rounded()))%")
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(AppColor.primaryText)
                }
                .font(.system(size: 13))
                .frame(width: 400)

                Text(repository.displayPath)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.tertiaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 400, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .task {
            try? await Task.sleep(for: .seconds(Self.duration + Self.lingerAfterDone))
            guard !Task.isCancelled else { return }
            onFinish()
        }
    }
}

// MARK: - Private methods -

private extension OpeningRepositoryView {
    /// Linear progress with a slight wobble, so it feels like real work is being done.
    static func progress(at elapsed: TimeInterval) -> Double {
        let u = min(1, elapsed / duration)
        return max(0, min(1, u - sin(2 * .pi * u * 2) / (2 * .pi * 2) * 0.7))
    }

    static func stepLabel(for progress: Double) -> String {
        guard progress < 1 else { return "Done" }
        return (steps.first { progress < $0.until } ?? steps[steps.count - 1]).label
    }
}
