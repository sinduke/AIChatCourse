//
//  OnboardingColorView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct OnboardingColorView: View {
    @State private var selectedColor: Color?
    let profileColors: [Color] = [
        .gray, .blue, .green, .orange, .brown, .indigo, .mint, .teal, .cyan
    ]
    var body: some View {
        ScrollView {
            colorGrid
                .padding(.horizontal, 24)
        }
        .safeAreaInset(
            edge: .bottom,
            alignment: .center,
            spacing: 16,
            content: {
                ZStack {
                    if let selectedColor {
                        catButton(selectColor: selectedColor)
                            .transition(.move(edge: .bottom))
                    }
                }
                .padding(24)
                .background(.background)
            }
        )
        .animation(.easeInOut(duration: 0.3), value: selectedColor != nil)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func catButton(selectColor: Color) -> some View {
        NavigationLink {
            OnboardingCompletedView(selectColor: selectColor)
        } label: {
            Text("continue".capitalized)
                .callToActionButton()
        }
    }
    
    private var colorGrid: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 16, alignment: nil),
                count: 3
            ),
            alignment: .center,
            spacing: 16,
            pinnedViews: [.sectionHeaders]) {
                Section {
                    ForEach(profileColors, id: \.self) { color in
                        Circle()
                            .fill(Color.accentColor)
                            .overlay(content: {
                                color
                                    .clipShape(.circle)
                                    .padding(selectedColor == color ? 10 : 0)
                            })
                            .onTapGesture {
                                if selectedColor != color {
                                    selectedColor = color
                                } else {
                                    selectedColor = nil
                                }
                            }
                    }
                } header: {
                    Text("Select a Profile Color")
                        .font(.headline)
                }

            }
    }
}

#Preview {
    NavigationStack {
        OnboardingColorView()
    }
    .environment(AppState())
}
