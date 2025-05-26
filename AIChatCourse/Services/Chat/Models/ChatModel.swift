//
//  ChatModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/17/25.
//

import SwiftUI
import IdentifiableByString

struct ChatModel: Identifiable, Codable, Hashable, StringIdentifiable {
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
    
    static func chatId(userId: String, avatarId: String) -> String {
        "\(userId)_\(avatarId)"
    }
    
    static func new(userId: String, avatarId: String) -> Self {
        Self(
            id: chatId(userId: userId, avatarId: avatarId),
            userId: userId,
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
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now,
                dateModified: now
            ),
            ChatModel(
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(minutes: -10),   // 10 分钟前
                dateModified: now.addingTimeInterval(minutes: -5)    // 5  分钟前
            ),
            ChatModel(
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(hours: -1),      // 1  小时前
                dateModified: now.addingTimeInterval(minutes: -30)   // 30 分钟前
            ),
            ChatModel(
                userId: UserAuthInfo.mock().uid,
                avatarId: AvatarModel.mocks.randomElement()!.avatarId,
                dateCreated: now.addingTimeInterval(hours: -2),      // 2  小时前
                dateModified: now.addingTimeInterval(hours: -2)      // 同上
            )
        ]
    }
}
