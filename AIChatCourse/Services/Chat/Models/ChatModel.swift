//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import SwiftUI

struct ChatModel: Identifiable {
    let id: String
    let userId: String
    let avatarId: String
    let dateCreated: Date
    let dateModified: Date
    
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
}

extension ChatModel {
    
    static var mock: ChatModel {
        mocks.first!
    }
    
    static var mocks: [ChatModel] {
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
