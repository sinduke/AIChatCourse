//
//  UserManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/21/25.
//

import SwiftUI

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error>
    func deleteUser(userId: String) async throws
    func onBoardingCompleted(userId: String, profileColorHex: String) async throws
}

struct MockService: UserService {
    
    let currentUser: UserModel?
    
    init(user: UserModel? = nil) {
        self.currentUser = user
    }
    
    func saveUser(user: UserModel) async throws {
        
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, any Error> {
        AsyncThrowingStream { continuation in
            if let currentUser {
                continuation.yield(currentUser)
            }
        }
    }
    
    func deleteUser(userId: String) async throws {
        
    }
    
    func onBoardingCompleted(userId: String, profileColorHex: String) async throws {
        
    }
    
}

import FirebaseFirestore
import SwiftfulFirestore
struct FirebaseUserService: UserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection
            .document(user.userId)
            .setData(from: user, merge: true)
    }
    
    func onBoardingCompleted(userId: String, profileColorHex: String) async throws {
        try await collection.document(userId).updateData([
            UserModel.CodingKeys.didCompleteOnboarding.rawValue: true,
            UserModel.CodingKeys.profileColorHex.rawValue: profileColorHex
        ])
    }
    
    func streamUser(userId: String) -> AsyncThrowingStream<UserModel, Error> {
        collection
            .streamDocument(id: userId)
    }
    
    func deleteUser(userId: String) async throws {
        try await collection.document(userId).delete()
    }
    
}

@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    private var currentUserListenerTask: Task<Void, Error>?
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
     func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
         let creationVersion = isNewUser ? Utilities.appVersion : nil
         let user = UserModel(auth: auth, creationVersion: creationVersion)
         try await service.saveUser(user: user)
         
         try? await Task.sleep(for: .seconds(5))
         
         addCurrentUserListener(userId: user.userId)
     }
    
    /**
     func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
         let creationVersion = isNewUser ? Utilities.appVersion : nil
         let user = UserModel(auth: auth, creationVersion: creationVersion)
         try await service.saveUser(user: user)

         try await withCheckedThrowingContinuation { continuation in
             Task {
                 do {
                     for try await value in service.streamUser(userId: user.userId, onListenerConfigured: { listener in
                         self.currentUserListener = listener
                     }) {
                         self.currentUser = value
                         dLog("监听成功，userId=\(value.userId)")
                         continuation.resume()
                         break
                     }
                 } catch {
                     continuation.resume(throwing: error)
                 }
             }
         }
     }
     */
    
    func addCurrentUserListener(userId: String) {
        currentUserListenerTask?.cancel()
        
        currentUserListenerTask = Task {
            do {
                for try await value in service.streamUser(userId: userId) {
                    self.currentUser = value
                }
            } catch {
                
            }
        }
        
    }
    
    func makeOnBoardingCompleteForCurrentUser(profileColorHex: String) async throws {
        let uid = try currentUserId()
        dLog(uid, .error)
        try await service.onBoardingCompleted(userId: uid, profileColorHex: profileColorHex)
    }
    
    func signOut() {
        currentUserListenerTask?.cancel()
        currentUserListenerTask = nil
        currentUser = nil
    }
    
    func deleteCurrentUser() async throws {
        let uid = try currentUserId()
        try await service.deleteUser(userId: uid)
        signOut()
    }
    
    private func currentUserId() throws -> String {
        
        dLog("开始打印User的ID信息")
        guard let uid = currentUser?.userId else {
            dLog("User的ID信息收集失败!", .error)
            throw UserManagerError.noUserId
        }
        return uid
    }
    
    enum UserManagerError: LocalizedError {
        case noUserId
    }
}
