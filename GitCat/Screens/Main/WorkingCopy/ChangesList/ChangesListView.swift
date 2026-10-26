//
//  ChangesListView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - ChangesListView -

struct ChangesListView: View {
    static let width: CGFloat = 360

    @ObservedObject private var viewModel: WorkingCopyViewModel

    // MARK: - Initializer -

    init(viewModel: WorkingCopyViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body -

    var body: some View {
        VStack(spacing: 0) {
            title
            files

            Rectangle()
                .fill(AppColor.line)
                .frame(height: 1)

            commitMessage
        }
        .frame(width: Self.width)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColor.line)
                .frame(width: 1)
        }
    }
}

// MARK: - Title -

private extension ChangesListView {
    var title: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Changes")
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.85)
                .foregroundStyle(AppColor.primaryText)

            Text(viewModel.changesSubtitle)
                .font(.system(size: 13))
                .foregroundStyle(AppColor.secondaryText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 36)
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }
}

// MARK: - Files -

private extension ChangesListView {
    var files: some View {
        ScrollView {
            VStack(spacing: 28) {
                if !viewModel.stagedFiles.isEmpty {
                    section(title: "Staged · \(viewModel.stagedFiles.count)",
                            actionTitle: "Unstage All",
                            action: viewModel.unstageAll,
                            files: viewModel.stagedFiles)
                }

                if !viewModel.unstagedFiles.isEmpty {
                    section(title: "Unstaged · \(viewModel.unstagedFiles.count)",
                            actionTitle: "Stage All",
                            action: viewModel.stageAll,
                            files: viewModel.unstagedFiles)
                }

                if viewModel.isClean {
                    Text("No local changes.")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColor.tertiaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 16)
        }
        .frame(maxHeight: .infinity)
    }

    func section(title: String, actionTitle: String, action: @escaping () -> Void, files: [ChangedFile]) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColor.secondaryText)

                Spacer()

                Button(actionTitle, action: action)
                    .buttonStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.accent)
            }
            .padding(.bottom, 10)

            ForEach(files) { file in
                ChangedFileRowView(file: file, isSelected: file.id == viewModel.selectedFile?.id)
                    // Selection reaches past the list's padding.
                    .padding(.horizontal, -10)
                    .onTapGesture(count: 2) { viewModel.toggleStage(file) }
                    .simultaneousGesture(TapGesture().onEnded { viewModel.select(file) })
                    .contextMenu {
                        Button(file.isStaged ? "Unstage" : "Stage") { viewModel.toggleStage(file) }
                        Divider()
                        Button("Discard Changes…") { viewModel.requestDiscard(file) }
                    }
                    .transition(.opacity.combined(with: .offset(y: 8)))
            }
        }
    }
}

// MARK: - Commit message -

private extension ChangesListView {
    var commitMessage: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Summary", text: $viewModel.summary)
                .font(.system(size: 15, weight: .semibold))
                .tracking(-0.15)
                .foregroundStyle(AppColor.primaryText)

            TextField("Description", text: $viewModel.commitDescription, axis: .vertical)
                .font(.system(size: 13))
                .lineSpacing(3)
                .foregroundStyle(AppColor.secondaryText)
                .lineLimit(3, reservesSpace: true)

            HStack {
                Toggle(isOn: $viewModel.pushesAfterCommit) {
                    Text("Push to \(viewModel.remoteName)")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColor.secondaryText)
                }
                .toggleStyle(CheckboxToggleStyle())
                .fixedSize()

                Spacer()

                Button(viewModel.commitTitle, action: viewModel.commit)
                    .buttonStyle(PrimaryPillButtonStyle())
                    .disabled(!viewModel.canCommit)
                    .keyboardShortcut(.return, modifiers: .command)
            }
            .padding(.top, 10)
        }
        .textFieldStyle(.plain)
        .padding(.top, 20)
        .padding(.horizontal, 28)
        .padding(.bottom, 24)
    }
}
