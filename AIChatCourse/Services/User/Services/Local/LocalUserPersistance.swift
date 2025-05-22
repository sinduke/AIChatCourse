//
//  LocalUserPersistance.swift
//  AIChatCourse
//
//  Created by sinduke on 5/22/25.
//

import SwiftUI

protocol LocalUserPersistance {
    func getCurrentUser() -> UserModel?
    func saveCurrentUser(user: UserModel?) throws
}
