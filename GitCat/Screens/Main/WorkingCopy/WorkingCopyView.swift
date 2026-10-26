//
//  WorkingCopyView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - WorkingCopyView -

/// Branch bar with fetch, pull and push on top, changed files on the left and the selected file's diff on the right.
struct WorkingCopyView: View {
    static let headerHeight: CGFloat = 52

    @ObservedObject private var viewModel: WorkingCopyViewModel

    // MARK: - Initializer -

    init(viewModel: WorkingCopyViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body -

    var body: some View {
        VStack(spacing: 0) {
            header

            Rectangle()
                .fill(AppColor.line)
                .frame(height: 1)

            HStack(spacing: 0) {
                ChangesListView(viewModel: viewModel)
                detail
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .overlay(alignment: .bottom) { status }
        .confirmationDialog("Discard changes to \(viewModel.fileToDiscard?.name ?? "file")?",
                            isPresented: Binding(get: { viewModel.fileToDiscard != nil },
                                                 set: { if !$0 { viewModel.fileToDiscard = nil } }),
                            presenting: viewModel.fileToDiscard) { file in
            Button("Discard Changes", role: .destructive) { viewModel.discard(file) }
            Button("Cancel", role: .cancel) { }
        } message: { file in
            Text(file.isStaged
                 ? "Staged changes and any changes made since staging them will be lost. This can't be undone."
                 : "Unstaged changes will be lost. This can't be undone.")
        }
    }
}

// MARK: - Header -

private extension WorkingCopyView {
    var header: some View {
        HStack(spacing: 20) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(viewModel.branchTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColor.primaryText)

                Text(viewModel.syncTitle)
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.tertiaryText)
            }
            .lineLimit(1)

            Spacer()

            Button(action: viewModel.fetch) {
                busyLabel(viewModel.fetchTitle, isBusy: viewModel.operation == .fetch)
            }
            .buttonStyle(HeaderTextButtonStyle())

            Button(action: viewModel.pull) {
                busyLabel(viewModel.pullTitle, isBusy: viewModel.operation == .pull)
            }
            .buttonStyle(HeaderTextButtonStyle())

            Button(viewModel.pushTitle, action: viewModel.push)
                .buttonStyle(PlainPillButtonStyle(size: .small))
        }
        .disabled(viewModel.operation != nil)
        .padding(.horizontal, 24)
        .frame(height: Self.headerHeight)
    }

    func busyLabel(_ title: String, isBusy: Bool) -> some View {
        HStack(spacing: 6) {
            if isBusy {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.7)
                    .frame(width: 16, height: 16)
            }
            Text(title)
        }
    }
}

// MARK: - Detail -

private extension WorkingCopyView {
    @ViewBuilder var detail: some View {
        if let diffViewModel = viewModel.diffViewModel {
            DiffView(viewModel: diffViewModel,
                     onToggleStage: viewModel.toggleStageOfSelectedFile,
                     onDiscard: viewModel.requestDiscardOfSelectedFile)
            .id(diffViewModel.file.id)
            .transition(.opacity.combined(with: .offset(y: 6)))
        } else if viewModel.isClean {
            cleanWorkingTree
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
        } else {
            Color.clear
        }
    }

    var cleanWorkingTree: some View {
        VStack(spacing: 14) {
            CatIdleGlyphView()
                .frame(width: 120)
                .padding(.bottom, 10)

            Text("Working tree clean.")
                .font(.system(size: 56, weight: .bold))
                .tracking(-1.96)
                .foregroundStyle(AppColor.primaryText)
                .minimumScaleFactor(0.5)

            Text(viewModel.cleanSubtitle)
                .font(.system(size: 15))
                .foregroundStyle(AppColor.secondaryText)
                .multilineTextAlignment(.center)

            if viewModel.commitsToPush > 0 {
                Button(viewModel.pushCommitsTitle, action: viewModel.push)
                    .buttonStyle(PrimaryPillButtonStyle())
                    .disabled(viewModel.operation != nil)
                    .padding(.top, 14)
            }
        }
        .lineLimit(1)
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Push progress and toasts -

private extension WorkingCopyView {
    @ViewBuilder var status: some View {
        Group {
            if viewModel.operation == .push {
                PushProgressView(destination: viewModel.pushDestination)
                    .transition(.opacity.combined(with: .offset(y: 16)).combined(with: .scale(scale: 0.96)))
            } else if let toast = viewModel.toast {
                Text(toast)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColor.background)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .frame(minHeight: 36)
                    .background(Capsule().fill(AppColor.primaryText))
                    .frame(maxWidth: 520)
                    .id(toast)
                    .transition(.opacity.combined(with: .offset(y: 16)).combined(with: .scale(scale: 0.96)))
            }
        }
        .padding(.bottom, 28)
        .animation(.spring(response: 0.42, dampingFraction: 0.7), value: viewModel.operation == .push)
    }
}

// MARK: - PushProgressView -

/// Dark capsule with the yarn ball loader looping while a push runs.
private struct PushProgressView: View {
    private static let loopDuration: TimeInterval = 2.4

    @Environment(\.colorScheme) private var colorScheme

    let destination: String

    var body: some View {
        HStack(spacing: 8) {
            TimelineView(.animation) { context in
                let time = context.date.timeIntervalSinceReferenceDate
                CatLoaderView(progress: time.truncatingRemainder(dividingBy: Self.loopDuration) / Self.loopDuration,
                              isDone: false)
                .frame(width: 210)
                // Only the band with the cat and the track is shown.
                .offset(y: -6)
                .frame(height: 38)
                .clipped()
            }
            // Drawn on a capsule in the primary text color, so the loader uses the opposite color scheme.
            .environment(\.colorScheme, colorScheme == .dark ? .light : .dark)

            Text("Pushing to \(destination)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppColor.background)
                .lineLimit(1)
        }
        .padding(.leading, 12)
        .padding(.trailing, 24)
        .frame(height: 56)
        .background(Capsule().fill(AppColor.primaryText))
    }
}

// MARK: - HeaderTextButtonStyle -

/// Text only button that brightens on hover.
private struct HeaderTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HeaderTextButton(configuration: configuration)
    }

    private struct HeaderTextButton: View {
        @Environment(\.isEnabled) private var isEnabled
        @State private var isHovered = false

        let configuration: ButtonStyleConfiguration

        var body: some View {
            configuration.label
                .font(.system(size: 13))
                .foregroundStyle(isHovered && isEnabled ? AppColor.primaryText : AppColor.secondaryText)
                .contentShape(Rectangle())
                .opacity(configuration.isPressed ? 0.7 : 1)
                .onHover { isHovered = $0 }
        }
    }
}
