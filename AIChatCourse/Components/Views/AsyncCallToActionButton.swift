//
//  AsyncCallToActionButton.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct AsyncCallToActionButton: View {
    var isLoading: Bool = false
    var title: String = "Save"
    var action: () -> Void
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text(title.uppercased())
            }
        }
        .callToActionButton()
        .anyButton(.press) {
            action()
        }
        .disabled(isLoading)
    }
}

private struct PreviewView: View {
    @State private var isLoading: Bool = false
    var body: some View {
        AsyncCallToActionButton(
            isLoading: isLoading,
            title: "Save") {
                isLoading = true
                Task {
                    defer {
                        isLoading = false
                    }
                    try? await Task.sleep(for: .seconds(3))
                    
                }
            }
    }
}

#Preview {
    PreviewView()
        .padding()
}
