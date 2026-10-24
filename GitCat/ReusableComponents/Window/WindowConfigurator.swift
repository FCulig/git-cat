//
//  WindowConfigurator.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - WindowConfigurator -

/// Switches the window between two looks:
/// - `fixedSize` set: content fills the whole window, including the area under the transparent title bar (only the
///   traffic lights float above it), and the window is locked to exactly that size.
/// - `fixedSize` nil: regular resizable window with a title bar and toolbar.
///
/// SwiftUI's `.windowResizability(.contentSize)` always reserves room for the title bar on top of the content size,
/// which is why the fixed size is applied directly on the `NSWindow`.
struct WindowConfigurator: NSViewRepresentable {
    let fixedSize: CGSize?

    func makeNSView(context: Context) -> NSView { NSView() }

    func updateNSView(_ view: NSView, context: Context) {
        // The view is attached to its window only after this pass.
        DispatchQueue.main.async { [fixedSize] in
            guard let window = view.window else { return }
            apply(fixedSize: fixedSize, to: window)
        }
    }
}

// MARK: - Private methods -

private extension WindowConfigurator {
    func apply(fixedSize: CGSize?, to window: NSWindow) {
        let isFixed = fixedSize != nil

        window.styleMask.insert(.fullSizeContentView)
        window.titlebarAppearsTransparent = isFixed
        window.titleVisibility = isFixed ? .hidden : .visible
        window.isMovableByWindowBackground = isFixed
        window.standardWindowButton(.zoomButton)?.isEnabled = !isFixed

        if let fixedSize {
            window.styleMask.remove(.resizable)
            if window.contentView?.frame.size != fixedSize {
                // Keep the top left corner in place, like AppKit does when resizing.
                var frame = window.frameRect(forContentRect: CGRect(origin: .zero, size: fixedSize))
                frame.origin = CGPoint(x: window.frame.minX, y: window.frame.maxY - frame.height)
                window.setFrame(frame, display: true)
            }
        } else {
            window.styleMask.insert(.resizable)
        }
    }
}
