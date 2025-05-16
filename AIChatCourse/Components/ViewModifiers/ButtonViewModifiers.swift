//
//  ButtonViewModifiers.swift
//  AIChatCourse
//
//  Created by sinduke on 5/16/25.
//

import SwiftUI

struct HightlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                configuration.isPressed ? Color.accent.opacity(0.4) : Color.accent.opacity(0)
            }
            .animation(.smooth, value: configuration.isPressed)
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.smooth, value: configuration.isPressed)
    }
}

enum ButtonStyleOption {
case press, highlight, plain
}

extension View {
    
    @ViewBuilder
    func anyButton( _ option: ButtonStyleOption = .plain, action: @escaping () -> Void) -> some View {
        switch option {
        case .press:
            self.pressableButton(action: action)
        case .highlight:
            self.hightlightButton(action: action)
        case .plain:
            self.plainButton(action: action)
        }
    }
    
    private func hightlightButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(HightlightButtonStyle())
    }
    
    private func pressableButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(PressableButtonStyle())
    }
    
    private func plainButton(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        Text("Highlight Button Style")
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
            .anyButton(.highlight, action: {
                
            })
            .padding()
        
        Text("Press Button Style")
            .callToActionButton()
            .anyButton(.press, action: {
                
            })
            .padding()
        
        Text("Plain Button Style")
            .callToActionButton()
            .anyButton(.plain, action: {
                
            })
            .padding()
    }
}
