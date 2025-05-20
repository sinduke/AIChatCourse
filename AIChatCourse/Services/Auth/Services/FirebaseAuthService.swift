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
        
        try await user.delete()
    }
    
    enum AuthError: LocalizedError {
        case userNotFound
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "Current Authenticated User Not Found"
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
