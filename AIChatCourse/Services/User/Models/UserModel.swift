//
//  UserModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

struct UserModel: Codable {
    
    let userId: String
    let email: String?
    let isAnonymous: Bool?
    let creationDate: Date?
    let creationVersion: String?
    let lastSignInDate: Date?
    let didCompleteOnboarding: Bool?
    let profileColorHex: String?
    
    init(
        userId: String,
        email: String? = nil,
        isAnonymous: Bool? = nil,
        creationDate: Date? = nil,
        creationVersion: String? = nil,
        lastSignInDate: Date? = nil,
        didCompleteOnboarding: Bool? = nil,
        profileColorHex: String? = nil
    ) {
        self.userId = userId
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.creationVersion = creationVersion
        self.lastSignInDate = lastSignInDate
        self.didCompleteOnboarding = didCompleteOnboarding
        self.profileColorHex = profileColorHex
    }
    
    init(auth: UserAuthInfo, creationVersion: String?) {
        self
            .init(
                userId: auth.uid,
                email: auth.email,
                isAnonymous: auth.isAnonymous,
                creationDate: auth.creationDate,
                creationVersion: creationVersion,
                lastSignInDate: auth.lastSignInDate
            )
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case isAnonymous = "is_anonymous"
        case creationDate = "creation_date"
        case creationVersion = "creation_version"
        case lastSignInDate = "last_sign_in_date"
        case didCompleteOnboarding = "did_complete_onboarding"
        case profileColorHex = "profile_color_hex"
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
                creationDate: now,
                didCompleteOnboarding: true,
                profileColorHex: "#34C759"          // Red-orange
            ),
            UserModel(
                userId: "U002",
                creationDate: now.addingTimeInterval(hours: -5),
                didCompleteOnboarding: false,
                profileColorHex: "#FF5733"          // iOS Green
            ),
            UserModel(
                userId: "U003",
                creationDate: now.addingTimeInterval(days: -1, hours: -2),
                didCompleteOnboarding: true,
                profileColorHex: "#5AC8FA"          // iOS Blue
            )
        ]
    }()
}
