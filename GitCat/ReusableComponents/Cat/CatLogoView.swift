//
//  CatLogoView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import Lottie
import SwiftUI

// MARK: - CatLogoView -

/// App icon styled git cat that comes to life (blinks, glances, kneads...)
struct CatLogoView: View {
    private static let animation = LottieAnimation.named("cat-idle")
    private static let configuration = LottieConfiguration(renderingEngine: .mainThread)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @StateObject private var animator = CatIdleAnimator()

    var size: CGFloat = 96
    var isAnimating = true

    var body: some View {
        LottieView(animation: Self.animation)
            .configuration(Self.configuration)
            .resizable()
            .playbackMode(playbackMode)
            .frame(width: size, height: size)
            .shadow(color: .black.opacity(0.12), radius: 15, y: 10)
            .onAppear(perform: updateAnimator)
            .onDisappear(perform: animator.stop)
            .onChange(of: isAnimating) { updateAnimator() }
            .onChange(of: reduceMotion) { updateAnimator() }
    }
}

// MARK: - Private methods -

private extension CatLogoView {
    var playbackMode: LottiePlaybackMode {
        guard let clip = animator.clip else { return .paused(at: .frame(0)) }
        return .playing(.marker(clip.markerName, loopMode: .playOnce))
    }

    func updateAnimator() {
        animator.isPaused = !isAnimating || reduceMotion
        if !animator.isPaused { animator.start() }
    }
}

#Preview {
    CatLogoView()
        .padding(40)
}
