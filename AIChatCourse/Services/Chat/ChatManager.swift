//
//  ChatManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

import SwiftUI

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
    
    func getAllChat(userId: String) async throws -> [ChatModel] {
        try await service.getAllChat(userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await service.getLastChatMessage(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await service.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatForDeleteUser(userId: String) async throws {
        try await service.deleteAllChatForDeleteUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        let reportChat = ReportModel.new(chatId: chatId, userId: userId)
        try await service.reportChat(report: reportChat)
    }
}
