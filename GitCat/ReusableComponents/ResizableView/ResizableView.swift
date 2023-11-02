//
//  ResizableView.swift
//  GitCat
//
//  Created by Filip Čulig on 01.11.2023..
//

import SwiftUI

// MARK: - ResizableView -
struct ResizableView<Content: View>: View {
    @Binding private var width: CGFloat
    @ViewBuilder private let content: Content
    private let dividerLocation: Edge.Set
    
    // MARK: - Initializer -
    
    init(width: Binding<CGFloat> = .constant(.zero),
         dividerLocation: Edge.Set = [],
         content: @escaping (() -> Content) = { EmptyView() }) {
        self._width = width
        self.dividerLocation = dividerLocation
        self.content = content()
    }
    
    // MARK: - Body -
    
    var body: some View {
        GeometryReader{ geometry in
            resetSize(geometry: geometry)
            
            VStack(spacing: 0) {
                if dividerLocation.contains(.top) {
                    divider()
                }
                
                Spacer()
                HStack(spacing: 0) {
                    if dividerLocation.contains(.leading) {
                        divider()
                    }
                    
                    Spacer()
                    content
                    Spacer()
                    
                    if dividerLocation.contains(.trailing) {
                        divider()
                    }
                }
                Spacer()
                
                if dividerLocation.contains(.bottom) {
                    divider()
                }
            }
        }
    }
    
    func resetSize(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            width = geometry.size.width
        }
        return EmptyView()
    }
    
    func divider() -> some View {
        Divider()
            .background(.red)
    }
}
