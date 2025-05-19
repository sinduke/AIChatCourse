//
//  View+EXT.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

// command + shift + o 快捷打开
extension View {
    func callToActionButton() -> some View {
        self
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(.accent)
            .cornerRadius(16)
    }
    
    func badgeButton() -> some View {
        self
            .font(.caption)
            .bold()
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(.blue)
            .cornerRadius(6)
    }
    
    func removeListRowFormatting() -> some View {
        self
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
    }
    
    func addingGradientbackgroundForText() -> some View {
        self
            .background(
                LinearGradient(
                    colors: [
                        .black.opacity(0),
                        .black.opacity(0.3),
                        .black.opacity(0.4)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    // 在SwiftUI中慎用 仅仅bool控制的是非才允许使用  慎用。慎用
    @ViewBuilder
    func ifSatisfiedCondition(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
