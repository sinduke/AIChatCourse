//
//  FileManagerUserPersistance.swift
//  AIChatCourse
//
//  Created by sinduke on 5/22/25.
//

import SwiftUI

struct FileManagerUserPersistance: LocalUserPersistance {
    
    private let userDocumentKey: String = "current_user"
    
    func getCurrentUser() -> UserModel? {
        FileManager.getDocument(key: userDocumentKey)
    }
    
    func saveCurrentUser(user: UserModel?) throws {
        try FileManager.saveDocument(key: userDocumentKey, value: user)
    }
}
