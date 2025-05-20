//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ChatsView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List(chats) { chat in
                ChatRowCellViewBuilder(
                    currentUserId: nil, /// "TOsDO  Add Cuid"
                    chat: chat) {
                        try? await Task.sleep(for: .seconds(1))
                        return AvatarModel.mocks.randomElement()
                    } getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(2))
                        return ChatMessageModel.mocks.randomElement()
                    }
                    .anyButton(.highlight, action: {
                        onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
            }
            .navigationTitle("ChatView")
            .navigationDestinationForCoreModult(path: $path)
        }
    }
    
    // MARK: -- Funcation
    private func onChatPressed(chat: ChatModel) {
        path.append(.chat(avatarId: chat.avatarId))
    }
}

#Preview {
    ChatsView()
}
