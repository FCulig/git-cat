//
//  PillButtonStyle.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - PrimaryPillButtonStyle -

/// Accent colored capsule button.
struct PrimaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HoverableLabel(configuration: configuration) { isHovered in
            configuration.label
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 32)
                .background(Capsule().fill(isHovered ? AppColor.accentHighlighted : AppColor.accent))
        }
    }
}

// MARK: - SecondaryPillButtonStyle -

/// Full width capsule button with a subtle outline.
struct SecondaryPillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(AppColor.primaryText)
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .background(Capsule().fill(AppColor.buttonBackground))
            .overlay(Capsule().strokeBorder(AppColor.windowLine, lineWidth: 0.5))
            .shadow(color: AppColor.line, radius: 1, y: 1)
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// MARK: - PlainPillButtonStyle -

/// Capsule button on a subtle fill, for actions next to a primary pill button or in a toolbar.
struct PlainPillButtonStyle: ButtonStyle {
    enum Size {
        /// 26pt tall, for toolbars.
        case small
        /// 32pt tall, same as `PrimaryPillButtonStyle`.
        case regular
    }

    var size: Size = .regular

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size == .small ? 12 : 13, weight: .medium))
            .foregroundStyle(AppColor.primaryText)
            .lineLimit(1)
            .padding(.horizontal, size == .small ? 14 : 18)
            .frame(height: size == .small ? 26 : 32)
            .background(Capsule().fill(AppColor.secondaryBackground))
            .contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// MARK: - HoverableLabel -

private struct HoverableLabel<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    let configuration: ButtonStyleConfiguration
    @ViewBuilder let content: (Bool) -> Content

    var body: some View {
        content(isHovered && isEnabled)
            .contentShape(Capsule())
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.35)
            .animation(.easeOut(duration: 0.25), value: isEnabled)
            .onHover { isHovered = $0 }
            .animation(.easeOut(duration: 0.15), value: isHovered)
    }
}
