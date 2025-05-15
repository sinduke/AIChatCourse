//
//  AvatarModel.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import Foundation

struct AvatarModel: Hashable {
    let avatarId: String
    let name: String?
    let characterOption: CharacterOption?
    let characterAction: CharacterAction?
    let characterLocation: CharacterLocation?
    let profileImageName: String?
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
 
    var characterDescription: String {
        AvatarDescriptionBuilder(avatar: self).charcaterDescription
    }
    
    static var mock: AvatarModel {
        mocks[0]
    }
    
    static var mocks: [AvatarModel] {
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

struct AvatarDescriptionBuilder {
    let characterOption: CharacterOption
    let characterAction: CharacterAction
    let characterLocation: CharacterLocation
    
    init(characterOption: CharacterOption, characterAction: CharacterAction, characterLocation: CharacterLocation) {
        self.characterOption = characterOption
        self.characterAction = characterAction
        self.characterLocation = characterLocation
    }
    
    init(avatar: AvatarModel) {
        self.characterOption = avatar.characterOption ?? .default
        self.characterAction = avatar.characterAction ?? .default
        self.characterLocation = avatar.characterLocation ?? .default
    }
    
    var charcaterDescription: String {
        "A \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
}

enum CharacterOption: String {
    case man, woman, alien, dog, cat
    
    static var `default`: Self {
        .man
    }
}

enum CharacterAction: String {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    static var `default`: Self {
        .drinking
    }
}

enum CharacterLocation: String {
    case park, mall, museum, city, desert, forest, space
    static var `default`: Self {
        .park
    }
}
