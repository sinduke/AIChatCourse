//
//  FirebaseChatService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseChatService: ChatService {
    
    private var collection: CollectionReference {
        Firestore.firestore().collection("chats")
    }
    
    private var chatReportsCollection: CollectionReference {
        Firestore.firestore().collection("chat_reports")
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
        // 这是第一种让数据库执行筛选查询的一种方式
//        let result: [ChatModel] = try await collection
//            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
//            .whereField(ChatModel.CodingKeys.avatarId.rawValue, isEqualTo: avatarId)
//            .getAllDocuments()
//        
//        return result.first
        
        // 第二种查询方式(设计的时候取巧)
        try await collection.getDocument(id: ChatModel.chatId(userId: userId, avatarId: avatarId))
    }
    
    func getAllChat(userId: String) async throws -> [ChatModel] {
        try await collection
            .whereField(ChatModel.CodingKeys.userId.rawValue, isEqualTo: userId)
            .getAllDocuments()
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        let message: [ChatMessageModel] = try await messageCollection(chatId: chatId)
            .order(by: ChatMessageModel.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: 1)
            .getAllDocuments()
        
        return message.first
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
    
    func deleteChat(chatId: String) async throws {
        async let deleteChat: () = collection.deleteDocument(id: chatId)
        // 删除对话的时候 对话中的聊天内容也需要一并删除
        async let deleteMessage: () = messageCollection(chatId: chatId).deleteAllDocuments()
        
        let (_, _) = await (try deleteChat, try deleteMessage)
    }
    
    func deleteAllChatForDeleteUser(userId: String) async throws {
        let chats = try await getAllChat(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for chat in chats {
                try await deleteChat(chatId: chat.id)
            }
            try await group.waitForAll()
        }
    }
    
    func reportChat(report: ReportModel) async throws {
        try await chatReportsCollection.setDocument(document: report)
    }
}
