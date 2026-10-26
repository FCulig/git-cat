//
//  SidebarView.swift
//  GitCat
//
//  Created by Filip Čulig on 24.10.2026..
//

import SwiftUI

// MARK: - SidebarView -
struct SidebarView: View {
    // TODO: Make the sidebar resizable.
    static let width: CGFloat = 232

    @ObservedObject private var viewModel: SidebarViewModel

    // MARK: - Initializer -

    init(viewModel: SidebarViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body -

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            titleBar
            repository

            List {
                workspace
                branches
                remotes
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .padding(.horizontal, 12)
        .font(.system(size: 13))
        .foregroundStyle(AppColor.primaryText)
        .frame(width: Self.width)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(AppColor.secondaryBackground)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppColor.line)
                .frame(width: 1)
        }
    }
}

// MARK: - Header -

private extension SidebarView {
    /// Row shared with the window's traffic lights.
    var titleBar: some View {
        HStack {
            Spacer()

            Image(.catGlyph)
                .resizable()
                .scaledToFit()
                .frame(width: 20)
                .foregroundStyle(AppColor.tertiaryText)
                .help("git cat")
        }
        .padding(.horizontal, 6)
        .frame(height: 28)
        .padding(.top, 10)
    }

    var repository: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(viewModel.repositoryName)
                .font(.system(size: 15, weight: .semibold))
                .tracking(-0.15)

            Text(viewModel.repositoryPath)
                .font(.system(size: 11))
                .foregroundStyle(AppColor.tertiaryText)
                .truncationMode(.middle)
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
    }
}

// MARK: - Sections -

private extension SidebarView {
    var workspace: some View {
        SidebarSection("Workspace") {
            ForEach(SidebarItem.allCases) { item in
                let isSelected = item == viewModel.selectedItem

                SidebarRow(isSelected: isSelected) {
                    Text(item.title)
                        .fontWeight(isSelected ? .medium : .regular)
                } accessory: {
                    if let count = viewModel.count(for: item) {
                        Text("\(count)")
                            .monospacedDigit()
                            .foregroundStyle(AppColor.tertiaryText)
                    }
                }
                .onTapGesture { viewModel.select(item) }
                .help(item.isAvailable ? "" : "Coming soon")
            }
        }
    }

    var branches: some View {
        SidebarSection("Branches") {
            ForEach(viewModel.branches, id: \.self) { branch in
                let isCurrent = branch == viewModel.currentBranch

                SidebarRow {
                    Text(branch)
                        .fontWeight(isCurrent ? .semibold : .regular)
                        .foregroundStyle(isCurrent ? AppColor.primaryText : AppColor.secondaryText)
                        .truncationMode(.middle)
                } accessory: {
                    if isCurrent {
                        Text("Current")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(AppColor.accent)
                    }
                }
                .help(branch)
            }

            if viewModel.currentBranch == nil {
                SidebarRow {
                    Text("Detached HEAD")
                        .fontWeight(.semibold)
                }
            }
        }
    }

    @ViewBuilder var remotes: some View {
        if !viewModel.remotes.isEmpty {
            SidebarSection("Remotes") {
                ForEach(viewModel.remotes, id: \.self) { remote in
                    SidebarRow {
                        Text(remote)
                            .foregroundStyle(AppColor.secondaryText)
                    }
                }
            }
        }
    }
}
