//
//  AvatarManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI

protocol AvatarService: Sendable {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

struct MockAvatarService: AvatarService {
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        
    }
}

import FirebaseFirestore
import SwiftfulFirestore

struct FirebaseAvatarService: AvatarService {
    
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
}

@MainActor
@Observable
class AvatarManager {
    private let service: AvatarService
    
    init(service: AvatarService) {
        self.service = service
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await service.createAvatar(avatar: avatar, image: image)
    }
    
}
