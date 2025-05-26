//
//  ReportModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/26/25.
//

import SwiftUI
import IdentifiableByString

struct ReportModel: StringIdentifiable, Codable {
    let id: String
    let chatId: String
    let userId: String
    let isActive: Bool
    let dateCreated: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case userId = "user_id"
        case isActive = "is_active"
        case dateCreated = "date_created"
    }
    
    static func new(chatId: String, userId: String) -> Self {
        Self(
            id: UUID().uuidString,
            chatId: chatId,
            userId: userId,
            isActive: true,
            dateCreated: .now
        )
    }
}
