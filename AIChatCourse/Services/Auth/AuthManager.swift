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
    private let logManager: LogManager?
    private(set) var auth: UserAuthInfo?
    private var listener: (any NSObjectProtocol)?
    
    init(service: AuthService, logManager: LogManager? = nil) {
        self.service = service
        self.logManager = logManager
        self.auth = service.getAuthenticatedUser()
        self.addAuthListener()
    }
    
    // MARK: -- Funcation
    private func addAuthListener() {
        logManager?.trackEvent(event: Event.authListenerStart)
        
        if let listener {
            service.removeAuthenticatedUserListener(listener: listener)
        }
        
        Task {
            for await value in service.addAuthenticatedUserListener(onListenerAttached: { listenerse in
                self.listener = listenerse
            }) {
                self.auth = value
                logManager?.trackEvent(event: Event.authListenerSuccess(user: value))
                if let value {
                    logManager?.identifyUser(userId: value.uid, name: nil, email: value.email)
                    logManager?.addUserProperties(dict: value.eventParameters, isHighPriority: true)
                    logManager?.addUserProperties(dict: Utilities.eventParameters, isHighPriority: false)
                }
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
        // 使用苹果账号登出的时候 要切换一个新的listener
        defer {
            addAuthListener()
        }
        
        return try await service.signInWithApple()
    }
    func signOut() throws {
        logManager?.trackEvent(event: Event.signOutStart)
        try service.signOut()
        auth = nil
        logManager?.trackEvent(event: Event.signOutSuccess)
    }
    func deleteAccount() async throws {
        logManager?.trackEvent(event: Event.deleteAccountStart)
        try await service.deleteAccount()
        auth = nil
        logManager?.trackEvent(event: Event.deleteAccountSuccess)
    }
    
    // MARK: -- Enum
    enum AuthError: LocalizedError {
        case notSignedIn
    }
    
    enum Event: LoggableEvent {
        case authListenerStart
        case authListenerSuccess(user: UserAuthInfo?)
        case signOutStart
        case signOutSuccess
        case deleteAccountStart
        case deleteAccountSuccess
        
        var eventName: String {
            switch self {
            case .authListenerStart: return "AuthManager_AuthListener_Start"
            case .authListenerSuccess: return "AuthManager_AuthListener_Success"
            case .signOutStart: return "AuthManager_SignOut_Start"
            case .signOutSuccess: return "AuthManager_SignOut_Success"
            case .deleteAccountStart: return "AuthManager_DeleteAccount_Start"
            case .deleteAccountSuccess: return "AuthManager_DeleteAccount_Success" 
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .authListenerSuccess(let user): return user?.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
        
    }
}
