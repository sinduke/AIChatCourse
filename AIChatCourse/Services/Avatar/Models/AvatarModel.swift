//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import Foundation
import IdentifiableByString

struct AvatarModel: Hashable, Codable, StringIdentifiable {
    
    var id: String {
        avatarId
    }
    
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    private(set) var profileImageName: String?
    let authorId: String?
    let dateCreated: Date?
    
    init(
        avatarId: String,
        name: String? = nil,
        characterOption: CharacterOption? = nil,
        characterAction: CharacterAction? = nil,
        characterLocation: CharacterLocation? = nil,
        profileImageName: String? = nil,
        authorId: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.avatarId = avatarId
        self.name = name
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
        self.profileImageName = profileImageName
        self.authorId = authorId
        self.dateCreated = dateCreated
    }
    
    // 模型内部自己处理数据的更新
    mutating func updateProfileImageName(imageName: String) {
        profileImageName = imageName
    }
    
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).charcaterDescription
    }
    
    static var mock: Self {
        mocks[0]
    }
    
    enum CodingKeys: String, CodingKey {
        case avatarId = "avatar_id"
        case name
        case characterOption = "character_option"
        case characterAction = "character_action"
        case characterLocation = "character_location"
        case profileImageName = "profile_image_name"
        case authorId = "author_id"
        case dateCreated = "date_created"
    }
    
    static var mocks: [Self] {
        let now = Date()
        return [
            AvatarModel(
                avatarId: "A001",
                name: "Alice",
                characterOption: .woman,
                characterAction: .smiling,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorId: "U001",
                dateCreated: now
            ),
            AvatarModel(
                avatarId: "A002",
                name: "Bob",
                characterOption: .man,
                characterAction: .walking,
                characterLocation: .city,
                profileImageName: Constants.randomImage,
                authorId: "U002",
                dateCreated: now.addingTimeInterval(-3_600)          // 1 h 前
            ),
            AvatarModel(
                avatarId: "A003",
                name: "Cathy",
                characterOption: .alien,
                characterAction: .studying,
                characterLocation: .museum,
                profileImageName: Constants.randomImage,
                authorId: "U003",
                dateCreated: now.addingTimeInterval(-7_200)          // 2 h 前
            ),
            AvatarModel(
                avatarId: "A004",
                name: "Duke",
                characterOption: .dog,
                characterAction: .relaxing,
                characterLocation: .forest,
                profileImageName: Constants.randomImage,
                authorId: "U004",
                dateCreated: now.addingTimeInterval(-10_800)         // 3 h 前
            ),
            AvatarModel(
                avatarId: "A005",
                name: "Eva",
                characterOption: .woman,
                characterAction: .shopping,
                characterLocation: .mall,
                profileImageName: Constants.randomImage,
                authorId: "U005",
                dateCreated: now.addingTimeInterval(-14_400)
            ),
            AvatarModel(
                avatarId: "A006",
                name: "Finn",
                characterOption: .cat,
                characterAction: .eating,
                characterLocation: .desert,
                profileImageName: Constants.randomImage,
                authorId: "U006",
                dateCreated: now.addingTimeInterval(-18_000)
            ),
            AvatarModel(
                avatarId: "A007",
                name: "Grace",
                characterOption: .woman,
                characterAction: .working,
                characterLocation: .city,
                profileImageName: Constants.randomImage,
                authorId: "U007",
                dateCreated: now.addingTimeInterval(-21_600)
            ),
            AvatarModel(
                avatarId: "A008",
                name: "Hank",
                characterOption: .man,
                characterAction: .drinking,
                characterLocation: .park,
                profileImageName: Constants.randomImage,
                authorId: "U008",
                dateCreated: now.addingTimeInterval(-25_200)
            ),
            AvatarModel(
                avatarId: "A009",
                name: "Iris",
                characterOption: .alien,
                characterAction: .fighting,
                characterLocation: .space,
                profileImageName: Constants.randomImage,
                authorId: "U009",
                dateCreated: now.addingTimeInterval(-28_800)
            ),
            AvatarModel(
                avatarId: "A010",
                name: "Jack",
                characterOption: .man,
                characterAction: .crying,
                characterLocation: .forest,
                profileImageName: Constants.randomImage,
                authorId: "U010",
                dateCreated: now.addingTimeInterval(-32_400)
            )
        ]
    }
}
