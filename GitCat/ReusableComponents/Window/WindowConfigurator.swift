//
//  WindowConfigurator.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - WindowConfigurator -

/// Content always fills the whole window, including the area under the transparent title bar (only the traffic lights
/// float above it). The window is either:
/// - `fixedSize` set: locked to exactly that size, and moved by dragging anywhere in it.
/// - `fixedSize` nil: resizable. It gets `resizableSize` when it stops being fixed.
///
/// SwiftUI's `.windowResizability(.contentSize)` always reserves room for the title bar on top of the content size,
/// which is why the fixed size is applied directly on the `NSWindow`.
struct WindowConfigurator: NSViewRepresentable {
    let fixedSize: CGSize?
    var resizableSize: CGSize?

    func makeNSView(context: Context) -> NSView { NSView() }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func updateNSView(_ view: NSView, context: Context) {
        let coordinator = context.coordinator
        // The view is attached to its window only after this pass.
        DispatchQueue.main.async { [fixedSize, resizableSize] in
            guard let window = view.window else { return }
            apply(fixedSize: fixedSize, resizableSize: resizableSize, to: window, coordinator: coordinator)
        }
    }
}

// MARK: - Coordinator -

extension WindowConfigurator {
    final class Coordinator {
        /// SwiftUI makes the window resizable again on its own, so the style mask can't tell whether it was fixed.
        var wasFixed = false
    }
}

// MARK: - Private methods -

private extension WindowConfigurator {
    func apply(fixedSize: CGSize?, resizableSize: CGSize?, to window: NSWindow, coordinator: Coordinator) {
        let isFixed = fixedSize != nil
        let wasFixed = coordinator.wasFixed
        coordinator.wasFixed = isFixed

        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = isFixed
        window.standardWindowButton(.zoomButton)?.isEnabled = !isFixed

        if let fixedSize {
            window.styleMask.remove(.resizable)
            if window.contentView?.frame.size != fixedSize {
                resize(window, to: fixedSize, animated: false)
            }
        } else {
            window.styleMask.insert(.resizable)
            if wasFixed, let resizableSize {
                resize(window, to: resizableSize, animated: true)
            }
        }
    }

    func resize(_ window: NSWindow, to contentSize: CGSize, animated: Bool) {
        var size = contentSize
        if let visibleFrame = window.screen?.visibleFrame {
            size.width = min(size.width, visibleFrame.width)
            size.height = min(size.height, visibleFrame.height)
        }

        // Keep the top left corner in place, like AppKit does when resizing.
        var frame = window.frameRect(forContentRect: CGRect(origin: .zero, size: size))
        frame.origin = CGPoint(x: window.frame.minX, y: window.frame.maxY - frame.height)
        if let visibleFrame = window.screen?.visibleFrame {
            // Growing must not push the window off the screen.
            frame.origin.x = min(max(frame.minX, visibleFrame.minX), visibleFrame.maxX - frame.width)
            frame.origin.y = min(max(frame.minY, visibleFrame.minY), visibleFrame.maxY - frame.height)
        }
        window.setFrame(frame, display: true, animate: animated)
    }
}
