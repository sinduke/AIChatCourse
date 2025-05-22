//
//  AuthManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/21/25.
//

import SwiftUI

@MainActor
@Observable
class AuthManager {
    
    private let service: AuthService
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService) {
        self.service = service
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    // MARK: -- Funcation
    private func addAuthListener() {
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listenerse in
                self.listener = listenerse
            }) {
                self.auth = value
            }
        }
    }
    
    func getAuthId() throws -> String {
        guard let uid = auth?.uid else {
            throw AuthError.notSignedIn
        }
        return uid
    }
    
    // MARK: -- 使用service的方法 但是不必刻意遵守AuthService协议
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInAnonymously()
    }
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await service.signInWithApple()
    }
    func signOut() throws {
        try service.signOut()
        auth = nil
    }
    func deleteAccount() async throws {
        try await service.deleteAccount()
        auth = nil
    }
    
    // MARK: -- AuthError
    enum AuthError: LocalizedError {
        case notSignedIn
    }
}
