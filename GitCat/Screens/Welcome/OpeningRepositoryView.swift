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

    private let progress: OpeningProgress

    // MARK: - Initializer -

    init(progress: OpeningProgress) {
        self.progress = progress
    }

    // MARK: - Body -

    var body: some View {
        // Redrawn every frame, so the loader glides between the fractions reported by finished steps.
        TimelineView(.animation) { context in
            let fraction = progress.fraction(at: context.date)

            VStack(spacing: 6) {
                CatLoaderView(progress: fraction, isDone: progress.isDone)
                    .frame(width: 440)

                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 6) {
                        Text("Opening \(progress.repository.name)")
                            .fontWeight(.semibold)
                            .foregroundStyle(AppColor.primaryText)
                        Text(progress.label)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                    .lineLimit(1)

                    Spacer()

                    Text("\(Int((fraction * 100).rounded()))%")
                        .fontWeight(.semibold)
                        .monospacedDigit()
                        .foregroundStyle(AppColor.primaryText)
                }
                .font(.system(size: 13))
                .frame(width: 400)

                Text(progress.repository.displayPath)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.tertiaryText)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(width: 400, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}
