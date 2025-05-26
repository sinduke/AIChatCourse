//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore
struct FirebaseChatService: ChatService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private func messageCollection(chatId: String) -> CollectionReference {
        collection
            .document(chatId)
            .collection("messages")
    }
    
    func createNewChat(chat: ChatModel) async throws {
        try collection.document(chat.id).setData(from: chat, merge: true)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        // 奇怪 这个函数为什么不是异步?
        try messageCollection(chatId: chatId)
            .document(message.id)
            .setData(from: message, merge: true)
        
        // 更新时间
        try await collection
            .document(chatId)
            .updateData([
                ChatModel.CodingKeys.dateModified.rawValue: Date.now
            ])
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
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
}
