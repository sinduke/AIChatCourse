//
//  UserManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/21/25.
//

import SwiftUI

protocol UserService: Sendable {
    func saveUser(user: UserModel) async throws
}

import FirebaseFirestore
struct FirebaseUserService: UserService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("users")
    }
    
    func saveUser(user: UserModel) async throws {
        try collection
            .document(user.userId)
            .setData(from: user, merge: true)
    }
    
}

@MainActor
@Observable
class UserManager {
    private let service: UserService
    private(set) var currentUser: UserModel?
    
    init(service: UserService) {
        self.service = service
        self.currentUser = nil
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        let creationVersion = isNewUser ? Utilities.appVersion : nil
        let user = UserModel(auth: auth, creationVersion: creationVersion)
        
        try await service.saveUser(user: user)
    }
    
}
