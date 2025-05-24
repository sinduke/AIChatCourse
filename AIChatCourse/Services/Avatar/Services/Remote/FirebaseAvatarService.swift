//
//  FirebaseAvatarService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: RemoteAvatarService {
    
    var collection: CollectionReference {
        Firestore.firestore().collection("avatars")
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        // 上传
        let path = "avatars/\(avatar.avatarId)"
        let url = try await FirebaseImageUploadService().uploadImage(image: image, path: path)
        
        // 更新图片地址
        var avatar = avatar
        avatar.updateProfileImageName(imageName: url.absoluteString)
        
        // 更新储存的模型
        try collection
            .document(avatar.avatarId)
            .setData(from: avatar, merge: true)
        
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await collection
            .order(by: AvatarModel.CodingKeys.clickCount.rawValue, descending: true)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await collection
            .limit(to: 50)
            .getAllDocuments()
            .first(upTo: 6) ?? []
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.characterOption.rawValue, isEqualTo: category.rawValue)
            .limit(to: 200)
            .getAllDocuments()
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try await collection
            .whereField(AvatarModel.CodingKeys.authorId.rawValue, isEqualTo: userId)
        // 可以在数据库中操作。速度会更快 但是firebase会给你添加索引
            .order(by: AvatarModel.CodingKeys.dateCreated.rawValue, descending: true)
            .getAllDocuments()
//            .sorted { ($0.dateCreated ?? .distantPast) > ($1.dateCreated ?? .distantPast) }
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await collection.getDocument(id: id)
    }
    
    func removeAuthorIdFromAvatar(avatarId: String) async throws {
        try await collection
            .document(avatarId)
            .updateData([
                AvatarModel.CodingKeys.authorId.rawValue: NSNull()
            ])
    }
    
    func removeAuthorIdFromAllAvatars(userId: String) async throws {
        let avatars = try await getAvatarsForAuth(userId: userId)
        
        try await withThrowingTaskGroup(of: Void.self) { group in
            for avatar in avatars {
                group.addTask {
                    try await removeAuthorIdFromAvatar(avatarId: avatar.avatarId)
                }
            }
            try await group.waitForAll()
        }
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await collection
            .document(avatarId)
            .updateData([
                AvatarModel.CodingKeys.clickCount.rawValue: FieldValue.increment(Int64(1))
            ])
    }
    
}
