//
//  ChatMessageModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import Foundation

// MARK: - ChatMessageModel
struct ChatMessageModel: Identifiable, Hashable {
    let id: String
    let chatId: String
    let authorId: String?
    let content: String?
    let seenByIds: [String]?
    let dateCreated: Date?
    
    init(
        id: String = UUID().uuidString,
        chatId: String,
        authorId: String? = nil,
        content: String? = nil,
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
}

// MARK: - Mock Data
extension ChatMessageModel {
    
    /// 单条示例（方便 SwiftUI Preview）
    static var mock: ChatMessageModel { mocks.first! }
    
    /// 5 条示例消息
    static let mocks: [ChatMessageModel] = {
        let now = Date()
        
        return [
            ChatMessageModel(
                chatId: "A001",
                authorId: "U001",
                content: "Hello, how are you?",
                seenByIds: ["U002", "U003"],
                dateCreated: now.addingTimeInterval(minutes: -5)
            ),
            ChatMessageModel(
                chatId: "A001",
                authorId: "U002",
                content: "I'm good, thanks! And you?",
                seenByIds: ["U001", "U003"],
                dateCreated: now.addingTimeInterval(minutes: -4)
            ),
            ChatMessageModel(
                chatId: "A002",
                authorId: "U003",
                content: "Anyone up for coffee later?",
                seenByIds: [],
                dateCreated: now.addingTimeInterval(minutes: -3)
            ),
            ChatMessageModel(
                chatId: "A001",
                authorId: "U001",
                content: "Doing great. Working on the SwiftUI project.",
                seenByIds: nil,
                dateCreated: now.addingTimeInterval(minutes: -2)
            ),
            ChatMessageModel(
                chatId: "A002",
                authorId: "U004",
                content: "Sure, let's meet at 4pm ☕️",
                seenByIds: ["U003"],
                dateCreated: now.addingTimeInterval(minutes: -1)
            )
        ]
    }()
}
