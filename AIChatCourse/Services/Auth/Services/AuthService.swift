//
//  AuthService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/21/25.
//

import SwiftUI

extension EnvironmentValues {
    
//    @Entry var authService: FirebaseAuthService = FirebaseAuthService()
    /// 支持 上方数据 并支持 Preview 数据
    @Entry var authService: AuthService = MockAuthService()
}

protocol AuthService: Sendable {
    
    func getAuthenticatedUser() -> UserAuthInfo?
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func signOut() throws
    func deleteAccount() async throws
    
}
