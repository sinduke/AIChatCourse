//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI
import FirebaseAuth

extension EnvironmentValues {
    @Entry var authService: FirebaseAuthService = FirebaseAuthService()
}

struct UserAuthInfo: Sendable {
    let uid: String
    let email: String?
    let isAnonymous: Bool
    let creationDate: Date?
    let lastSingInDate: Date?
    
    init(
        uid: String,
        email: String? = nil,
        isAnonymous: Bool = false,
        creationDate: Date? = nil,
        lastSingInDate: Date? = nil
    ) {
        self.uid = uid
        self.email = email
        self.isAnonymous = isAnonymous
        self.creationDate = creationDate
        self.lastSingInDate = lastSingInDate
    }
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.isAnonymous = user.isAnonymous
        self.creationDate = user.metadata.creationDate
        self.lastSingInDate = user.metadata.lastSignInDate
    }
}

struct FirebaseAuthService {
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return UserAuthInfo(user: user)
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        let user = UserAuthInfo(user: result.user)
        let isNewUser = result.additionalUserInfo?.isNewUser ?? true
        
        return (user, isNewUser)
    }
}
