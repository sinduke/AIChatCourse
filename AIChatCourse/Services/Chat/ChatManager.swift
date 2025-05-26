//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore
struct FirebaseChatService: ChatService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
}

@MainActor
@Observable
class ChatManager {
    private let service: ChatService
    
    init(service: ChatService) {
        self.service = service
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try await service.createNewChat(chat: chat)
    }
}
