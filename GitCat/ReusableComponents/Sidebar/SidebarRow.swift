//
//  SidebarRow.swift
//  GitCat
//
//  Created by Filip Čulig on 26.10.2026..
//

import SwiftUI

// MARK: - SidebarRow -

/// Row of a `SidebarSection`: a single line title, with an optional accessory (e.g. a count) on the trailing edge.
struct SidebarRow<Title: View, Accessory: View>: View {
    private let isSelected: Bool
    private let title: Title
    private let accessory: Accessory

    // MARK: - Initializer -

    init(isSelected: Bool = false, @ViewBuilder title: () -> Title, @ViewBuilder accessory: () -> Accessory) {
        self.isSelected = isSelected
        self.title = title()
        self.accessory = accessory()
    }

    // MARK: - Body -

    var body: some View {
        HStack(spacing: 0) {
            title
            Spacer(minLength: 8)
            accessory
        }
        .lineLimit(1)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, minHeight: 28, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isSelected ? AppColor.sidebarSelection : .clear)
        )
        .contentShape(Rectangle())
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }
}

extension SidebarRow where Accessory == EmptyView {
    init(isSelected: Bool = false, @ViewBuilder title: () -> Title) {
        self.init(isSelected: isSelected, title: title) { EmptyView() }
    }
}

#Preview {
    List {
        SidebarRow(isSelected: true) {
            Text("Changes")
        } accessory: {
            Text("3")
                .foregroundStyle(AppColor.tertiaryText)
        }

        SidebarRow {
            Text("History")
        }
    }
    .listStyle(.sidebar)
    .frame(width: 232, height: 120)
}
