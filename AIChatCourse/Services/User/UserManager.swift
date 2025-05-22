//
//  UserManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/21/25.
//

import SwiftUI

@MainActor
@Observable
class UserManager {
    private let remote: RemoteUserService
    private let local: LocalUserPersistance
    private(set) var currentUser: UserModel?
    private var currentUserListenerTask: Task<Void, Error>?
    
    init(services: UserServices) {
        self.remote = services.remote
        self.local = services.local
        self.currentUser = local.getCurrentUser()
    }
    
     func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
         let creationVersion = isNewUser ? Utilities.appVersion : nil
         let user = UserModel(auth: auth, creationVersion: creationVersion)
         try await remote.saveUser(user: user)
         
         addCurrentUserListener(userId: user.userId)
     }
    
    func addCurrentUserListener(userId: String) {
        currentUserListenerTask?.cancel()
        
        currentUserListenerTask = Task {
            do {
                for try await value in remote.streamUser(userId: userId) {
                    self.currentUser = value
                    self.saveCurrentUserLocally()
                }
            } catch {
                
            }
        }
        
    }
    
    private func saveCurrentUserLocally() {
        Task {
            do {
                try local.saveCurrentUser(user: currentUser)
            } catch {
                dLog("本地保存用户信息出错: \(error)")
            }
        }
    }
    
    func makeOnBoardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        try await remote.onBoardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListenerTask?.cancel()
        currentUserListenerTask = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await remote.deleteUser(userId: uid)
        signOut()
    }
    
    private func currentUserId() throws -> String {
        guard let uid = currentUser?.userId else {
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
