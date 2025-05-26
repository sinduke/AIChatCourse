//
//  ChatService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

protocol ChatService: Sendable {
    func createNewChat(chat: ChatModel) async throws
    func getChat(userId: String, avatarId: String) async throws -> ChatModel?
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error>
    func getAllChat(userId: String) async throws -> [ChatModel]
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
    func deleteChat(chatId: String) async throws
    func deleteAllChatForDeleteUser(userId: String) async throws
    func reportChat(report: ReportModel) async throws
}
