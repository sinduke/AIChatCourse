//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
}

struct MockChatService: ChatService {
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        ChatModel.mock
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream {_ in
            
        }
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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
//        
//        return result.first
        
        // 第二种查询方式
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
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
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        messageCollection(chatId: chatId).streamAllDocuments()
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
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await service.getChat(userId: userId, avatarId: avatarId)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await service.addChatMessage(chatId: chatId, message: message)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        service.streamChatMessages(chatId: chatId)
    }
}
