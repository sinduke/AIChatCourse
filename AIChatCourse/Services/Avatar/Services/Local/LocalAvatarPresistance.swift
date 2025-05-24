//
//  LocalAvatarPresistance.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftUI

@MainActor
protocol LocalAvatarPresistance {
    func addRecentAvatar(avatar: AvatarModel) throws
    func getRecentAvatars() throws -> [AvatarModel]
}
