//
//  ModalSupportView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

extension View {
    func showModal(showModal: Binding<Bool>, @ViewBuilder content: () -> some View) -> some View {
        
        self
            .overlay {
                ModalSupportView(showModal: showModal) {
                    content()
                }
            }
    }
}

struct ModalSupportView<Content: View>: View {
    
    @Binding var showModal: Bool
    @ViewBuilder var content: Content
    
    var body: some View {
        ZStack {
            if showModal {
                Color.black.opacity(0.6).ignoresSafeArea()
                    .transition(AnyTransition.opacity.animation(.smooth))
                    .onTapGesture {
                        showModal = false
                    }
                    .zIndex(1)
                
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .zIndex(2)
            }
        }
        .zIndex(9999)
        .animation(.bouncy, value: showModal)
    }
}

private struct PreviewView: View {
    @State private var showModal: Bool = false
    var body: some View {
        Button("Click Me") {
            showModal.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .showModal(showModal: $showModal) {
            RoundedRectangle(cornerRadius: 30)
                .padding(40)
                .padding(.vertical, 100)
                .onTapGesture {
                    showModal = false
                }
//                .transition(.slide)
                .transition(.fade)
        }
    }
}

#Preview {
    PreviewView()
}
