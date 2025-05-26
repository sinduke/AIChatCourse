//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

struct ChatRowCellViewBuilder: View {
    
    var currentUserId: String? = ""
    var chat: ChatModel = .mock
    var getAvatar: () async -> AvatarModel?
    var getLastChatMessage: () async -> ChatMessageModel?
    
    @State private var avatar: AvatarModel?
    @State private var lastChatMessage: ChatMessageModel?
    
    @State private var didLoadAvatar: Bool = false
    @State private var didLoadChatMessage: Bool = false
    
    private var isLoading: Bool {
        !(didLoadAvatar && didLoadChatMessage)
    }
    
    private var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId else { return false }
        return lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    private var subheadline: String? {
        if isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        if avatar == nil && lastChatMessage == nil {
            return "Error loading data"
        }
        
        return lastChatMessage?.content?.content
    }
    
    var body: some View {
        ChatRowCellView(
            imageName: avatar?.profileImageName,
            headline: isLoading ? "xxx xxx" : avatar?.name,
            subheadline: subheadline,
            hasNewChat: isLoading ? false : hasNewChat
        )
        .redacted(reason: isLoading ? .placeholder : [])
        .task {
            avatar = await getAvatar()
            didLoadAvatar = true
        }
        .task {
            lastChatMessage = await getLastChatMessage()
            didLoadChatMessage = true
        }
    }
    
}

#Preview {
    VStack {
        ChatRowCellViewBuilder {
            try? await Task.sleep(for: .seconds(5))
            return .mock
        } getLastChatMessage: {
            try? await Task.sleep(for: .seconds(1))
            return .mock
        }
        
        ChatRowCellViewBuilder {
            .mock
        } getLastChatMessage: {
            .mock
        }
        
        ChatRowCellViewBuilder {
            nil
        } getLastChatMessage: {
            nil
        }
        
        ChatRowCellViewBuilder {
            nil
        } getLastChatMessage: {
            .mock
        }
    }
}
