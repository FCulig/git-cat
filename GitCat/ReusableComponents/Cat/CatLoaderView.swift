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
/// The whole opening sequence is baked into `cat-loader-light.json` / `cat-loader-dark.json`
/// (see Design/Lottie/generate_cat_loader.py), this view only picks the frame for the elapsed time.
struct CatLoaderView: View {
    private static let lightAnimation = LottieAnimation.named("cat-loader-light")
    private static let darkAnimation = LottieAnimation.named("cat-loader-dark")
    private static let configuration = LottieConfiguration(renderingEngine: .mainThread)
    private static let aspectRatio: CGFloat = 480 / 140

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Seconds since the loader appeared.
    let time: TimeInterval

    var body: some View {
        let animation = colorScheme == .dark ? Self.darkAnimation : Self.lightAnimation

        LottieView(animation: animation)
            .configuration(Self.configuration)
            .resizable()
            .currentFrame(frame(at: time, in: animation))
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
    }
}

// MARK: - Private methods -

private extension CatLoaderView {
    /// Maps elapsed time into the marker's frame range, holding the last frame once the sequence is over.
    func frame(at time: TimeInterval, in animation: LottieAnimation?) -> AnimationFrameTime {
        let marker = reduceMotion ? "openingReducedMotion" : "opening"
        guard let animation,
              let start = animation.frameTime(forMarker: marker),
              let duration = animation.durationFrameTime(forMarker: marker) else { return 0 }

        return start + min(max(0, time * animation.framerate), duration)
    }
}

#Preview {
    TimelineView(.animation) { context in
        CatLoaderView(time: context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3.05))
            .frame(width: 440)
            .padding(40)
    }
}
