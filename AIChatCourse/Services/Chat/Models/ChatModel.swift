//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import SwiftUI

struct ChatModel: Identifiable, Codable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case avatarId = "avatar_id"
        case dateCreated = "date_created"
        case dateModified = "date_modified"
    }
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        avatarId: String,
        dateCreated: Date = Date(),
        dateModified: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.avatarId = avatarId
        self.dateCreated = dateCreated
        self.dateModified = dateModified
    }
    
    static func new(chatId: String, avatarId: String) -> Self {
        Self(
            id: "\(chatId)_\(avatarId)",
            userId: chatId,
            avatarId: avatarId,
            dateCreated: .now,
            dateModified: .now
        )
    }
}

extension ChatModel {
    
    static var mock: Self {
        mocks.first!
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            ChatModel(
                userId: "U001",
                avatarId: "A001",
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                userId: "U002",
                avatarId: "A002",
                dateCreated: now.addingTimeInterval(minutes: -10),   // 10 分钟前
                dateModified: now.addingTimeInterval(minutes: -5)    // 5  分钟前
            ),
            ChatModel(
                userId: "U003",
                avatarId: "A003",
                dateCreated: now.addingTimeInterval(hours: -1),      // 1  小时前
                dateModified: now.addingTimeInterval(minutes: -30)   // 30 分钟前
            ),
            ChatModel(
                userId: "U004",
                avatarId: "A004",
                dateCreated: now.addingTimeInterval(hours: -2),      // 2  小时前
                dateModified: now.addingTimeInterval(hours: -2)      // 同上
            )
        ]
    }
}
