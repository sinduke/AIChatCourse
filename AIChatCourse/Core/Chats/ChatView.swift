//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ChatView: View {
    
    @State private var chats: [ChatModel] = ChatModel.mocks
    var body: some View {
        NavigationStack {
            List(chats) { chat in
                ChatRowCellViewBuilder(
                    currentUserId: nil, /// "TOsDO  Add Cuid"
                    chat: chat) {
                        try? await Task.sleep(for: .seconds(1))
                        return .mock
                    } getLastChatMessage: {
                        try? await Task.sleep(for: .seconds(2))
                        return .mock
                    }
                    .anyButton(.highlight, action: {
                        
                    })
                    .removeListRowFormatting()

            }
                .navigationTitle("ChatViewNavTitle")
        }
    }
}

#Preview {
    ChatView()
}
