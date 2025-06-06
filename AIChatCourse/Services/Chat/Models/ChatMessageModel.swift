//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import Foundation
import IdentifiableByString

// MARK: - ChatMessageModel
struct ChatMessageModel: Identifiable, Codable, StringIdentifiable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: AIChatModel?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String = UUID().uuidString,
        chatId: String,
        authorId: String? = nil,
        content: AIChatModel? = nil,
        seenByIds: [String]? = nil,
        dateCreated: Date? = Date()
    ) {
        self.id = id
        self.chatId = chatId
        self.authorId = authorId
        self.content = content
        self.seenByIds = seenByIds
        self.dateCreated = dateCreated
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case authorId = "author_id"
        case content
        case seenByIds = "seen_by_ids"
        case dateCreated = "date_created"
    }
    
    var eventParameters: [String: Any] {
        var dict: [String: Any?] = [
            "message_\(CodingKeys.id.rawValue)": id,
            "message_\(CodingKeys.chatId.rawValue)": chatId,
            "message_\(CodingKeys.authorId.rawValue)": authorId,
            "message_\(CodingKeys.seenByIds.rawValue)": seenByIds?.sorted().joined(separator: ", "),
            "message_\(CodingKeys.dateCreated.rawValue)": dateCreated
        ]
        dict.merge(content?.eventParameters)
        
        // 返回把Nil丢弃之后的值
        return dict.compactMapValues({ $0 })
    }
    
    var dateCreatedCalculated: Date {
        dateCreated ?? .distantPast
    }
    
    static func newUserSendMessage(chatId: String, userId: String, message: AIChatModel) -> ChatMessageModel {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: userId,
            content: message,
            seenByIds: [userId],
            dateCreated: .now
        )
    }
    
    static func newAIMessage(chatId: String, avatarId: String, message: AIChatModel) -> Self {
        ChatMessageModel(
            id: UUID().uuidString,
            chatId: chatId,
            authorId: avatarId,
            content: message,
            seenByIds: [],
            dateCreated: .now
        )
    }
    
}

// MARK: - Mock Data
extension ChatMessageModel {
    
    func hasBeenSeenBy(userId: String) -> Bool {
        guard let seenByIds else { return false }
        return seenByIds.contains(userId)
    }
    
    /// 单条示例（方便 SwiftUI Preview）
    static var mock: Self { mocks.first! }
    
    /// 5 条示例消息
    static let mocks: [Self] = {
        let now = Date()
        
        return [
            ChatMessageModel(
                chatId: "A001",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Hello, how are you?"),
                seenByIds: ["U002", "U003"],
                dateCreated: now.addingTimeInterval(-2 * 60 * 60)
            ),
            ChatMessageModel(
                chatId: "A001",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "I'm good, thanks! And you?"),
                seenByIds: ["U001", "U003"],
                dateCreated: now.addingTimeInterval(minutes: -74)
            ),
            ChatMessageModel(
                chatId: "A002",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .assistant, content: "Anyone up for coffee later?"),
                seenByIds: [],
                dateCreated: now.addingTimeInterval(minutes: -63)
            ),
            ChatMessageModel(
                chatId: "A001",
                authorId: UserAuthInfo.mock().uid,
                content: AIChatModel(role: .user, content: "Doing great. Working on the SwiftUI project."),
                seenByIds: nil,
                dateCreated: now.addingTimeInterval(minutes: -52)
            ),
            ChatMessageModel(
                chatId: "A002",
                authorId: AvatarModel.mock.avatarId,
                content: AIChatModel(role: .assistant, content: "Sure, let's meet at 4pm ☕️"),
                seenByIds: ["U003"],
                dateCreated: now.addingTimeInterval(minutes: -1)
            )
        ]
    }()
}
