//
//  DiffView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - DiffView -

struct DiffView: View {
    private static let lineHeight: CGFloat = 22
    private static let numberColumnWidth: CGFloat = 52
    private static let signColumnWidth: CGFloat = 24

    @ObservedObject private var viewModel: DiffViewModel
    @State private var isDiscardHovered = false

    private let onToggleStage: () -> Void
    private let onDiscard: () -> Void

    // MARK: - Initializer -

    init(viewModel: DiffViewModel, onToggleStage: @escaping () -> Void, onDiscard: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onToggleStage = onToggleStage
        self.onDiscard = onDiscard
    }

    // MARK: - Body -

    var body: some View {
        VStack(spacing: 0) {
            header
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Header -

private extension DiffView {
    var header: some View {
        HStack(alignment: .bottom, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.statusTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(viewModel.file.status.color)

                Text(viewModel.file.name)
                    .font(.system(size: 28, weight: .semibold))
                    .tracking(-0.56)
                    .foregroundStyle(AppColor.primaryText)
                    .truncationMode(.middle)

                Text(viewModel.directoryTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(AppColor.secondaryText)
                    .truncationMode(.head)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 20) {
                Button("Discard", action: onDiscard)
                    .buttonStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(isDiscardHovered ? AppColor.removedText : AppColor.secondaryText)
                    .onHover { isDiscardHovered = $0 }

                if viewModel.file.isStaged {
                    Button("Unstage", action: onToggleStage)
                        .buttonStyle(PlainPillButtonStyle())
                } else {
                    Button("Stage", action: onToggleStage)
                        .buttonStyle(PrimaryPillButtonStyle())
                }
            }
            .fixedSize()
        }
        .padding(.top, 36)
        .padding(.horizontal, 40)
        .padding(.bottom, 24)
    }
}

// MARK: - Content -

private extension DiffView {
    var content: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.line, lineWidth: 1)

            if let errorMessage = viewModel.errorMessage {
                message(errorMessage)
            } else if viewModel.isEmpty {
                message(viewModel.emptyMessage)
            } else {
                lines
            }
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 40)
    }

    var lines: some View {
        GeometryReader { geometry in
            ScrollView([.vertical, .horizontal]) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.lines) { line in
                        makeRow(for: line)
                    }
                }
                .padding(.vertical, 8)
                // Line backgrounds reach the right edge even when every line is short, and short diffs start at the top.
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
            }
        }
        .font(.system(size: 12, design: .monospaced))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    func makeRow(for line: DiffLine) -> some View {
        HStack(spacing: 0) {
            lineNumber(line.oldNumber)
            lineNumber(line.newNumber)

            Text(sign(of: line))
                .foregroundStyle(line.kind == .added ? AppColor.addedText : AppColor.removedText)
                .frame(width: Self.signColumnWidth)

            // Tabs are rendered too wide by Text.
            Text(line.text.replacingOccurrences(of: "\t", with: "    "))
                .foregroundStyle(line.kind == .hunk ? AppColor.tertiaryText : AppColor.primaryText)
                .fixedSize()
                .padding(.trailing, 24)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, minHeight: Self.lineHeight, alignment: .leading)
        .background(background(of: line))
    }

    func lineNumber(_ number: Int?) -> some View {
        Text(number.map(String.init) ?? "")
            .foregroundStyle(AppColor.tertiaryText)
            .opacity(0.7)
            .lineLimit(1)
            .padding(.trailing, 12)
            .frame(width: Self.numberColumnWidth, alignment: .trailing)
    }

    func message(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundStyle(AppColor.tertiaryText)
            .multilineTextAlignment(.center)
            .padding(24)
    }
}

// MARK: - Helpers -

private extension DiffView {
    func sign(of line: DiffLine) -> String {
        switch line.kind {
        case .added: "+"
        case .removed: "−"
        case .context, .hunk: ""
        }
    }

    func background(of line: DiffLine) -> Color {
        switch line.kind {
        case .hunk: AppColor.secondaryBackground
        case .added: AppColor.addedBackground
        case .removed: AppColor.removedBackground
        case .context: .clear
        }
    }
}
