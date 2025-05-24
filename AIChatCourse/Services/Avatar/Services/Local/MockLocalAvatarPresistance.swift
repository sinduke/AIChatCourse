//
//  MockLocalAvatarPersistence.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftUI

struct MockLocalAvatarPersistence: LocalAvatarPersistence {
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
