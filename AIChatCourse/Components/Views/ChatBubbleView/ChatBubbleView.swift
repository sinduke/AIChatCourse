//
//  ChatBubbleView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatBubbleView: View {
    var text: String = "This is sampling text"
    var textColor: Color = .primary
    var backgroundColor: Color = Color(uiColor: .systemGray6)
    var showImage: Bool = true
    var imageName: String?
    let offset: CGFloat = 16
    var body: some View {
        HStack(alignment: .top, spacing: 8.0) {
            if showImage {
                ZStack {
                    if let imageName {
                        ImageLoaderView(urlString: imageName)
                    } else {
                        Rectangle()
                            .fill(.secondary.opacity(0.5))
                    }
                }
                .frame(width: 45, height: 45)
                .clipShape(.circle)
                .offset(y: offset)
            }
            
            Text(text)
                .font(.body)
                .foregroundStyle(textColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                .background(backgroundColor)
                .cornerRadius(6)
        }
        .padding(.bottom, showImage ? offset : 0)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16.0) {
            ChatBubbleView()
            ChatBubbleView(text: "This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. ")
            ChatBubbleView()
            ChatBubbleView(
                textColor: .white,
                backgroundColor: .accent,
                showImage: false,
                imageName: nil
            )
            ChatBubbleView()
            ChatBubbleView(
                text: "This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. This is a large text. ",
                textColor: .white,
                backgroundColor: .accent,
                showImage: false,
                imageName: nil
            )
            ChatBubbleView()
        }
        .padding(8)
    }
}
