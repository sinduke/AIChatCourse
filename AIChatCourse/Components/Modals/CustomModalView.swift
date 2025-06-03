//
//  CustomModalView.swift
//  AIChatCourse
//
//  Created by sinduke on 6/3/25.
//

import SwiftUI

struct CustomModalView: View {

    var title: String = "Title"
    var subtitle: String? = "Subtitle"
    var primaryButtonTitle: String = "Yes"
    var secondaryButtonTitle: String = "No"
    var primaryButtonAction: () -> Void = {}
    var secondaryButtonAction: () -> Void = {}

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                if let subtitle {
                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)

            VStack(spacing: 8) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.accent)
                        .foregroundStyle(.white)
                        .cornerRadius(16)
                        .anyButton(.press, action: primaryButtonAction)

                    Text(secondaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.secondary)
                        .anyButton(.plain, action: secondaryButtonAction)
                }
            .padding(.horizontal)
        }
        .multilineTextAlignment(.center)
        .padding(.vertical)
        .background(.background)
        .cornerRadius(16)
        .padding()
        .shadow(radius: 10)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.5).ignoresSafeArea()
        CustomModalView(
            title: "Are you enjoying AIChat?",
            subtitle: "We'd love to hear your thoughts and feedback.",
            primaryButtonTitle: "Yes",
            secondaryButtonTitle: "No",
            primaryButtonAction: {
            },
            secondaryButtonAction: {
            })
    }
}
