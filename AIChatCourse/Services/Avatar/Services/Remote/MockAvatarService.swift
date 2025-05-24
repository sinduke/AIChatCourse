//
//  MockAvatarService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftUI

struct MockAvatarService: RemoteAvatarService {
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(1))
        return AvatarModel.mocks.shuffled()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mock
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        
    }
}
