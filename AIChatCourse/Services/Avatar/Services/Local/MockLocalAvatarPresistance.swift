//
//  MockLocalAvatarPresistance.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftUI

struct MockLocalAvatarPresistance: LocalAvatarPresistance {
    func addRecentAvatar(avatar: AvatarModel) throws {
        
    }
    func getRecentAvatars() throws -> [AvatarModel] {
        AvatarModel.mocks.shuffled()
    }
}
