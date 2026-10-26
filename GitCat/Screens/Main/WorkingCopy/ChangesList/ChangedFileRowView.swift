//
//  ChangedFileRowView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - ChangedFileRowView -

struct ChangedFileRowView: View {
    static let height: CGFloat = 38

    let file: ChangedFile
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(file.status.letter)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(file.status.color)
                .frame(width: 14, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(file.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColor.primaryText)
                    .layoutPriority(1)

                if let directory = file.directory {
                    Text(directory)
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.tertiaryText)
                        .truncationMode(.middle)
                }
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            lineCounts
        }
        .padding(.horizontal, 10)
        .frame(height: Self.height)
        .background(isSelected ? AppColor.rowSelection : .clear)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppColor.line)
                .frame(height: 1)
        }
        .contentShape(Rectangle())
        .help(file.path)
    }
}

// MARK: - Line counts -

private extension ChangedFileRowView {
    var lineCounts: some View {
        HStack(spacing: 6) {
            if let additions = file.additions, additions > 0 {
                Text("+\(additions)")
                    .foregroundStyle(AppColor.addedText)
            }
            if let deletions = file.deletions, deletions > 0 {
                Text("−\(deletions)")
                    .foregroundStyle(AppColor.removedText)
            }
        }
        .font(.system(size: 11, design: .monospaced))
        .fixedSize()
    }
}

// MARK: - FileStatus color -

extension FileStatus {
    var color: Color {
        switch self {
        case .new, .untracked, .copied: AppColor.addedText
        case .deleted, .unmerged: AppColor.removedText
        case .modified, .typeChanged: AppColor.modified
        case .renamed: AppColor.accent
        case .unmodified: AppColor.tertiaryText
        }
    }
}
