//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI

@MainActor
@Observable
class AvatarManager {
    private let remote: RemoteAvatarService
    private let local: LocalAvatarPresistance
    
    init(service: RemoteAvatarService, local: LocalAvatarPresistance = MockLocalAvatarPresistance()) {
        self.remote = service
        self.local = local
    }
    
    func addRecentAvatar(avatar: AvatarModel) throws {
        try local.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try local.getRecentAvatars()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await remote.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await remote.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await remote.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await remote.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try await remote.getAvatarsForAuth(userId: userId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await remote.getAvatar(id: id)
    }
}
