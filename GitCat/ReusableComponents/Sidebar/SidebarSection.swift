//
//  SidebarSection.swift
//  GitCat
//
//  Created by Filip Čulig on 26.10.2026..
//

import SwiftUI

// MARK: - SidebarSection -

/// Titled group of `SidebarRow`s in a sidebar `List`.
struct SidebarSection<Content: View>: View {
    private let title: String
    private let content: Content

    // MARK: - Initializer -

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    // MARK: - Body -

    var body: some View {
        Section {
            content
        } header: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppColor.tertiaryText)
                .padding(.horizontal, 8)
        }
    }
}

#Preview {
    List {
        SidebarSection("Remotes") {
            SidebarRow {
                Text("origin")
            }
        }
    }
    .listStyle(.sidebar)
    .frame(width: 232, height: 200)
}
