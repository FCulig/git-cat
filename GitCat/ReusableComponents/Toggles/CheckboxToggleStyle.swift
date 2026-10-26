//
//  CheckboxToggleStyle.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - CheckboxToggleStyle -

/// Rounded checkbox in the accent color, followed by the label. The whole row toggles it.
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(configuration.isOn ? AppColor.accent : AppColor.checkboxBackground)

                if configuration.isOn {
                    Path { path in
                        path.move(to: CGPoint(x: 1, y: 4))
                        path.addLine(to: CGPoint(x: 3.6, y: 6.6))
                        path.addLine(to: CGPoint(x: 9, y: 1.2))
                    }
                        .stroke(.white, style: StrokeStyle(lineWidth: 1.6, lineCap: .round, lineJoin: .round))
                        .frame(width: 10, height: 8)
                        .transition(.scale(scale: 0.6).combined(with: .opacity))
                } else {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .strokeBorder(AppColor.checkboxBorder, lineWidth: 1)
                }
            }
            .frame(width: 16, height: 16)
            .padding(.top, 1)

            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.15)) { configuration.isOn.toggle() }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(configuration.isOn ? "On" : "Off")
    }
}
