//
//  CatLoaderView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Lottie
import SwiftUI

// MARK: - CatLoaderView -

/// "Unspool" loader: the cat hops behind a ball of yarn that rolls along the track and leaves a green line behind.
///
/// Artwork comes from `cat-loader-light.json` / `cat-loader-dark.json` (see Design/Lottie/generate_cat_loader.py).
/// The file is drawn twice: its track section scrubbed to `progress`, and its cat section looping on top, shifted so
/// the cat follows the ball. That way the cat keeps hopping while progress waits for slow work.
struct CatLoaderView: View {
    // MARK: - Private properties -

    private static let lightAnimation = LottieAnimation.named("cat-loader-light")
    private static let darkAnimation = LottieAnimation.named("cat-loader-dark")
    private static let configuration = LottieConfiguration(renderingEngine: .mainThread)

    // Geometry of the animation, in its own coordinates. Must match generate_cat_loader.py.
    private static let size = CGSize(width: 480, height: 140)
    private static let ballStart: CGFloat = 36
    private static let trackLength: CGFloat = 420
    private static let catX: CGFloat = 240
    /// Distance between the cat's front paws and the ball's center.
    private static let catDistanceFromBall: CGFloat = 22

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Public properties -

    /// Between 0 and 1.
    let progress: Double
    /// Once done, the cat stops hopping and rests.
    let isDone: Bool

    // MARK: - Body -

    var body: some View {
        let animation = colorScheme == .dark ? Self.darkAnimation : Self.lightAnimation

        GeometryReader { geometry in
            let scale = geometry.size.width / Self.size.width

            ZStack {
                LottieView(animation: animation)
                    .configuration(Self.configuration)
                    .resizable()
                    .currentFrame(trackFrame(in: animation))

                LottieView(animation: animation)
                    .configuration(Self.configuration)
                    .resizable()
                    .playbackMode(catPlaybackMode)
                    .offset(x: catOffset * scale)
            }
        }
        .aspectRatio(Self.size, contentMode: .fit)
        .clipped()
    }
}

// MARK: - Private methods -

private extension CatLoaderView {
    var clampedProgress: CGFloat {
        CGFloat(min(1, max(0, progress)))
    }

    /// Shift of the cat section, which draws the cat at `catX`, so the cat ends up just behind the ball.
    var catOffset: CGFloat {
        Self.ballStart + clampedProgress * Self.trackLength - Self.catDistanceFromBall - Self.catX
    }

    func trackFrame(in animation: LottieAnimation?) -> AnimationFrameTime {
        let marker = reduceMotion ? "trackReducedMotion" : "track"
        guard let animation,
              let start = animation.frameTime(forMarker: marker),
              let duration = animation.durationFrameTime(forMarker: marker) else { return 0 }

        return start + clampedProgress * duration
    }

    var catPlaybackMode: LottiePlaybackMode {
        if reduceMotion {
            return .paused(at: .marker("catResting"))
        }
        return .playing(.marker(isDone ? "catResting" : "catHopping", loopMode: .loop))
    }
}

#Preview {
    TimelineView(.animation) { context in
        let time = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 4)
        CatLoaderView(progress: min(1, time / 3), isDone: time >= 3)
            .frame(width: 440)
            .padding(40)
    }
}
