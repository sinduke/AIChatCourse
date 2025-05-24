struct MockAvatarService: AvatarService {
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
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try? await Task.sleep(for: .seconds(2))
        return AvatarModel.mocks.shuffled()
    }
}