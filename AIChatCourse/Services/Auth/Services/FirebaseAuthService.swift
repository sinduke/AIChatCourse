//
//  FirebaseAuthService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI
import FirebaseAuth
import SignInAppleAsync

struct FirebaseAuthService: AuthService {
    
    // 转为异步流
    func addAuthenticatedUserListener(onListenerAttached: (any NSObjectProtocol) -> Void) -> AsyncStream<UserAuthInfo?> {
        AsyncStream { continuation in
            let listener = Auth.auth().addStateDidChangeListener { _, currentUser in
                if let currentUser {
                    let user = UserAuthInfo(user: currentUser)
                    continuation
                        .yield(user)
                } else {
                    continuation
                        .yield(nil)
                }
            }
            
            onListenerAttached(listener)
        }
    }
    
    func removeAuthenticatedUserListener(listener: any NSObjectProtocol) {
        Auth.auth().removeStateDidChangeListener(listener)
    }
    
    func getAuthenticatedUser() -> UserAuthInfo? {
        guard let user = Auth.auth().currentUser else {
            return nil
        }
        return UserAuthInfo(user: user)
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let result = try await Auth.auth().signInAnonymously()
        return result.asAuthInfo
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        let helper = await SignInWithAppleHelper()
        let response = try await helper.signIn()
        
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: response.token,
            rawNonce: response.nonce
        )
        
        // 如果已经有一个匿名账户的情况下 绑定匿名账户
        if let user = Auth.auth().currentUser, user.isAnonymous {
            do {
                let result = try await user.link(with: credential)
                return result.asAuthInfo
            } catch let error as NSError {
                let authError = AuthErrorCode(rawValue: error.code)
                switch authError {
                case .providerAlreadyLinked, .credentialAlreadyInUse:
                    if let authCredential = error.userInfo["FIRAuthErrorUserInfoUpdatedCredentialKey"] as? AuthCredential {
                        let result = try await Auth.auth().signIn(with: authCredential)
                        return result.asAuthInfo
                    }
                default:
                    break
                }
            }
        }
        
        // 创建新的苹果账号和匿名账号
        let result = try await Auth.auth().signIn(with: credential)
        return result.asAuthInfo
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
        } catch let error as NSError {
            let authError = AuthErrorCode(rawValue: error.code)
            switch authError {
            case .requiresRecentLogin:
                // 如果需要重新认证，则重新认证
                try await reAuthenticateUser(error: error)
                
                // 重新认证成功后，删除账户
                try await user.delete()
            default:
                throw error
            }
        }
    }

    private func reAuthenticateUser(error: Error) async throws {
        guard let user = Auth.auth().currentUser, let providerID = user.providerData.first?.providerID else {
            throw AuthError.userNotFound
        }

        switch providerID {
        case "apple.com":
            let result = try await signInWithApple()
            guard user.uid == result.user.uid else {
                throw AuthError.reAuthenticateChanged
            }
        default:
            throw error
        }
        
        // for item in user.providerData {
        //     dLog(item.providerID)
        // }
    }

    // MARK: -- Enum
    enum AuthError: LocalizedError {
        case userNotFound
        case reAuthenticateChanged
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current Authenticated User Not Found"
            case .reAuthenticateChanged:
                return "Re-Authenticate Changed, Please Check Your Account"
            }
        }
    }
}

extension AuthDataResult {
    var asAuthInfo: (user: UserAuthInfo, isNewUser: Bool) {
        let user = UserAuthInfo(user: user)
        let isNewUser = additionalUserInfo?.isNewUser ?? true
        
        return (user, isNewUser)
    }
}
