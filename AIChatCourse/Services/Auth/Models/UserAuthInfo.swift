//
//  UserAuthInfo.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

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
    
}
