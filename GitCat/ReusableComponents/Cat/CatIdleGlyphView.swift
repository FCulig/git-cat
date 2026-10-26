//
//  CatIdleGlyphView.swift
//  GitCat
//
//  Created by Filip Čulig on 26.10.2026..
//

import Lottie
import SwiftUI

// MARK: - CatIdleGlyphView -

/// Git cat sitting on a green and a red diff line that comes to life (blinks, glances, kneads...) while the user is
/// idle. Same artwork as the `CatGlyph` image, from `cat-glyph-light.json` / `cat-glyph-dark.json`
/// (see Design/Lottie/generate_cat_idle.py).
struct CatIdleGlyphView: View {
    // MARK: - Private properties -

    private static let lightAnimation = LottieAnimation.named("cat-glyph-light")
    private static let darkAnimation = LottieAnimation.named("cat-glyph-dark")
    private static let configuration = LottieConfiguration(renderingEngine: .mainThread)
    /// Width to height ratio of the artwork.
    private static let aspectRatio: CGFloat = 80 / 57

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var animator = CatIdleAnimator()

    // MARK: - Body -

    var body: some View {
        LottieView(animation: colorScheme == .dark ? Self.darkAnimation : Self.lightAnimation)
            .configuration(Self.configuration)
            .resizable()
            .playbackMode(playbackMode)
            .aspectRatio(Self.aspectRatio, contentMode: .fit)
            .onAppear(perform: updateAnimator)
            .onDisappear(perform: animator.stop)
            .onChange(of: reduceMotion) { updateAnimator() }
    }
}

// MARK: - Private methods -

private extension CatIdleGlyphView {
    var playbackMode: LottiePlaybackMode {
        guard let clip = animator.clip else { return .paused(at: .frame(0)) }
        return .playing(.marker(clip.markerName, loopMode: .playOnce))
    }

    func updateAnimator() {
        animator.isPaused = reduceMotion
        if !animator.isPaused { animator.start() }
    }
}

#Preview {
    CatIdleGlyphView()
        .frame(width: 120)
        .padding(40)
}
