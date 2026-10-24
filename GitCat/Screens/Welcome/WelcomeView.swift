//
//  WelcomeView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - WelcomeView -

/// Repository picker shown at launch, unless the user chose to always open a repository directly.
struct WelcomeView: View {
    static let size = CGSize(width: 880, height: 540)

    @ObservedObject private var viewModel: WelcomeViewModel
    @State private var hasAppeared = false
    @State private var isDropTargeted = false

    private let isActive: Bool

    // MARK: - Initializer -

    /// - Parameter isActive: Pass `false` while the welcome screen is covered, to pause the idle cat.
    init(viewModel: WelcomeViewModel, isActive: Bool = true) {
        self.viewModel = viewModel
        self.isActive = isActive
    }

    // MARK: - Body -

    var body: some View {
        HStack(spacing: 0) {
            introduction
            recents
        }
        // Window size is pinned to `size` by the root view, the content just fills it.
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .overlay {
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(AppColor.accent, lineWidth: 3)
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.15), value: isDropTargeted)
        .scaleEffect(hasAppeared ? 1 : 0.96)
        .opacity(hasAppeared ? 1 : 0)
        .ignoresSafeArea()
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted, perform: viewModel.handleDrop)
        .onAppear {
            withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.36)) { hasAppeared = true }
        }
        .alert("Invalid directory", isPresented: $viewModel.isShowingInvalidRepositoryAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Selected directory is not a git repository")
        }
    }
}

// MARK: - Introduction -

private extension WelcomeView {
    var introduction: some View {
        VStack(spacing: 0) {
            CatLogoView(isAnimating: isActive)

            Text(viewModel.heading)
                .font(.system(size: 34, weight: .bold))
                .tracking(-0.85)
                .foregroundStyle(AppColor.primaryText)
                .padding(.top, 28)

            Text(viewModel.subheading)
                .font(.system(size: 14))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.secondaryText)
                .frame(maxWidth: 300)
                .padding(.top, 10)

            VStack(spacing: 14) {
                Button("Choose Repository…", action: viewModel.chooseRepository)
                    .buttonStyle(PrimaryPillButtonStyle())

                Text("or drop a folder onto this window")
                    .font(.system(size: 12))
                    .foregroundStyle(AppColor.tertiaryText)
            }
            .padding(.top, 32)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            Text("Version \(viewModel.version)")
                .font(.system(size: 11))
                .foregroundStyle(AppColor.tertiaryText)
                .padding(.bottom, 18)
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.recents.isEmpty)
    }
}

// MARK: - Recents -

private extension WelcomeView {
    var recents: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColor.tertiaryText)
                .padding(.top, 22)
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            if viewModel.recents.isEmpty {
                Text("Repositories you open will show up here.")
                    .font(.system(size: 13))
                    .lineSpacing(3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppColor.tertiaryText)
                    .padding(32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            } else {
                recentsList
                    .transition(.opacity)

                Rectangle()
                    .fill(AppColor.line)
                    .frame(height: 1)

                recentsFooter
            }
        }
        .frame(width: 340)
        .frame(maxHeight: .infinity)
        .background(AppColor.secondaryBackground)
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(AppColor.line)
                .frame(width: 1)
        }
    }

    var recentsList: some View {
        ScrollView {
            // Refreshes "5m ago" labels while the screen stays open.
            TimelineView(.everyMinute) { context in
                VStack(spacing: 2) {
                    ForEach(viewModel.recents, id: \.animationID) { repository in
                        RecentRepositoryRowView(repository: repository,
                                                isSelected: repository == viewModel.selectedRepository,
                                                now: context.date)
                        .onTapGesture { viewModel.select(repository) }
                        .simultaneousGesture(TapGesture(count: 2).onEnded { viewModel.open(repository) })
                        .transition(.asymmetric(insertion: .opacity.combined(with: .offset(x: 24)),
                                                removal: .opacity))
                    }
                }
                .padding(.horizontal, 10)
            }
        }
        .frame(maxHeight: .infinity)
    }

    var recentsFooter: some View {
        VStack(spacing: 14) {
            Toggle(isOn: Binding(get: { viewModel.isAutoOpenEnabled }, set: viewModel.setAutoOpen)) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Always open \(viewModel.selectedRepository?.name ?? "") at launch")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppColor.primaryText)

                    Text(viewModel.isAutoOpenEnabled
                         ? "git cat skips this screen and opens it directly."
                         : "When off, git cat starts on this screen.")
                    .font(.system(size: 11))
                    .lineSpacing(2)
                    .foregroundStyle(AppColor.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(WelcomeCheckboxToggleStyle())

            Button("Open \(viewModel.selectedRepository?.name ?? "")", action: viewModel.openSelected)
                .buttonStyle(SecondaryPillButtonStyle())
                .keyboardShortcut(.defaultAction)
        }
        .padding(.top, 16)
        .padding(.horizontal, 20)
        .padding(.bottom, 18)
    }
}

// MARK: - WelcomeCheckboxToggleStyle -

private struct WelcomeCheckboxToggleStyle: ToggleStyle {
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

// MARK: - Helpers -

private extension RecentRepository {
    /// Changes whenever the repository is re-added, so it slides in again at the top of the list.
    var animationID: String { "\(path)|\(lastOpened.timeIntervalSince1970)" }
}
