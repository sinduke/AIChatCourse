//
//  CarouselView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/16/25.
//

import SwiftUI

struct CarouselView<Content: View, T: Hashable>: View {
    var items: [T]
    @State private var selection: T?
    @ViewBuilder var content: (T) -> Content
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        content(item)
                            .scrollTransition(
                                .interactive.threshold(.visible(0.95)),
                                axis: .horizontal,
                                transition: { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.9)
                                }
                            )
                            .id(item)
                            .containerRelativeFrame(.horizontal, alignment: .center)
                    }
                }
            }
            .frame(height: 200)
            .scrollIndicators(.hidden)
            .scrollTargetLayout()
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $selection)
            .onAppear {
                updateSelectionIfNeeded()
            }
            .onChange(of: items.count) { _, _ in
                updateSelectionIfNeeded()
            }
            
            HStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    Circle()
                        .fill(item == selection ? .accent : .secondary.opacity(0.5))
                        .frame(width: 8)
                }
            }
            .animation(.linear, value: selection)
        }
    }
    
    private func updateSelectionIfNeeded() {
        if selection == nil || selection == items.last {
            selection = items.first
        }
    }
}

#Preview {
    CarouselView(items: AvatarModel.mocks) { item in
        HeroCellView(
            title: item.name,
            subTitle: item.characterDescription,
            imageName: item.profileImageName
        )
    }
        .padding()
}
