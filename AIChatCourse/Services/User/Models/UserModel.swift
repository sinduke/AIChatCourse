//
//  UserModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

struct UserModel {
    
    let userId: String
    let dateCreated: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        dateCreated: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.dateCreated = dateCreated
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
}

extension UserModel {
    
    var profileColorCalculated: Color {
        Color(hex: profileColorHex ?? "") ?? .accent
    }
    
    /// 单条示例（SwiftUI Preview）
    static var mock: Self { mocks.first! }
    
    /// 三条示例用户（不可变，线程安全）
    static let mocks: [Self] = {
        let now = Date()
        return [
            UserModel(
                userId: "U001",
                dateCreated: now,
                didCompleteOnboarding: true,
                profileColorHex: "#34C759"          // Red-orange
            ),
            UserModel(
                userId: "U002",
                dateCreated: now.addingTimeInterval(hours: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"          // iOS Green
            ),
            UserModel(
                userId: "U003",
                dateCreated: now.addingTimeInterval(days: -1, hours: -2),
                didCompleteOnboarding: true,
                profileColorHex: "#5AC8FA"          // iOS Blue
            )
        ]
    }()
}
