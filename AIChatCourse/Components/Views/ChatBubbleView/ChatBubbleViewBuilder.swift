//
//  ChatBubbleViewBuilder.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatBubbleViewBuilder: View {
    var message: ChatMessageModel = ChatMessageModel.mock
    var isCurrentUser: Bool = false
    var imageName: String?
    var onImagePressed: (() -> Void)?
    
    var body: some View {
        ZStack {
            ChatBubbleView(
                text: message.content?.content ?? "",
                textColor: isCurrentUser ? .white : .primary,
                backgroundColor: isCurrentUser ? .accent : Color(uiColor: .systemGray6),
                showImage: !isCurrentUser,
                imageName: imageName,
                onImagePressed: onImagePressed
            )
            .frame(maxWidth: .infinity, alignment: isCurrentUser ? .trailing : .leading)
            .padding(.leading, isCurrentUser ? 70 : 0)
            .padding(.trailing, isCurrentUser ? 0 : 70)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder()
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(isCurrentUser: true)
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .user, content: "This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text."),
                    seenByIds: [],
                    dateCreated: .now
                )
            )
            
            ChatBubbleViewBuilder(
                message: ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: UUID().uuidString,
                    content: AIChatModel(role: .assistant, content: "This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text.This is a lang text."),
                    seenByIds: [],
                    dateCreated: .now
                ), isCurrentUser: true
            )
        }
        .padding()
    }
}
