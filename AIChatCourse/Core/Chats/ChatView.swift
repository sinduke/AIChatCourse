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
                /*@START_MENU_TOKEN@*/Text(chat.id)/*@END_MENU_TOKEN@*/
            }
                .navigationTitle("ChatViewNavTitle")
        }
    }
}

#Preview {
    ChatView()
}
