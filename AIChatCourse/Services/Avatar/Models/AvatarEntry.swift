//
//  AvatarEntry.swift
//  AIChatCourse
//
//  Created by sinduke on 5/24/25.
//

import SwiftData
import SwiftUI

@Model
class AvatarEntry {
    
    @Attribute(.unique) var avatarId: String
    var name: String?
    var characterOption: CharacterOption?
    var characterAction: CharacterAction?
    var characterLocation: CharacterLocation?
    var profileImageName: String?
    var authorId: String?
    var dateCreated: Date?
    var dateAdd: Date
    
    init(from model: AvatarModel) {
        self.avatarId = model.avatarId
        self.name = model.name
        self.characterOption = model.characterOption
        self.characterAction = model.characterAction
        self.characterLocation = model.characterLocation
        self.profileImageName = model.profileImageName
        self.authorId = model.authorId
        self.dateCreated = model.dateCreated
        self.dateAdd = .now
    }
    
    func toModel() -> AvatarModel {
        AvatarModel(
            avatarId: avatarId,
            name: name,
            characterOption: characterOption,
            characterAction: characterAction,
            characterLocation: characterLocation,
            profileImageName: profileImageName,
            authorId: authorId,
            dateCreated: dateCreated
        )
    }
}
