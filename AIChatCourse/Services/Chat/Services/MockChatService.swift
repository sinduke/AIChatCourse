//
//  MockChatService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

import SwiftUI

struct MockChatService: ChatService {
    
    let chats: [ChatModel]
    let delay: Double
    let showError: Bool
    
    init(chats: [ChatModel] = ChatModel.mocks, delay: Double = 0, showError: Bool = false) {
        self.chats = chats
        self.delay = delay
        self.showError = showError
    }
    
    private func tryShowError() throws {
        if showError {
            throw URLError(.unknown)
        }
    }
    
    func createNewChat(chat: ChatModel) async throws {
        
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats.first { chat in
            return chat.userId == userId && chat.avatarId == avatarId
        }
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        AsyncThrowingStream {_ in
            
        }
    }
    
    func getAllChat(userId: String) async throws -> [ChatModel] {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        return chats
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try? await Task.sleep(for: .seconds(delay))
        try tryShowError()
        
        return ChatMessageModel.mocks.randomElement()
    }
    
    func deleteChat(chatId: String) async throws {
        
    }
    
    func deleteAllChatForDeleteUser(userId: String) async throws {
        
    }
    
    func reportChat(report: ReportModel) async throws {
        
    }
}
