//
//  RecentRepositoryRowView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - RecentRepositoryRowView -
struct RecentRepositoryRowView: View {
    let repository: RecentRepository
    let isSelected: Bool
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(repository.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AppColor.primaryText)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(Self.relativeTime(from: repository.lastOpened, to: now))
                    .font(.system(size: 11))
                    .foregroundStyle(secondaryColor)
                    .fixedSize()
            }

            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(repository.displayPath)
                    .font(.system(size: 11))
                    .foregroundStyle(secondaryColor)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Text(repository.branch)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(secondaryColor)
                    .fixedSize()
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? AppColor.accent : .clear)
        )
        .contentShape(Rectangle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Private methods -

private extension RecentRepositoryRowView {
    var secondaryColor: Color {
        isSelected ? .white.opacity(0.75) : AppColor.tertiaryText
    }

    static func relativeTime(from date: Date, to now: Date) -> String {
        let minutes = Int(now.timeIntervalSince(date) / 60)
        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }

        let hours = minutes / 60
        if hours < 24 { return "\(hours)h ago" }

        let days = hours / 24
        return days == 1 ? "Yesterday" : "\(days)d ago"
    }
}
