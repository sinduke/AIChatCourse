//
//  AvatarAttributes.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

enum CharacterOption: String, CaseIterable, Hashable, Codable {
    case man, woman, alien, dog, cat
    
    static var `default`: Self {
        .man
    }
    
    var plural: String {
        switch self {
        case .man:
            "Men"
        case .woman:
            "Women"
        case .alien:
            "Aliens"
        case .dog:
            "Dogs"
        case .cat:
            "Cats"
        }
    }
    
    var startsWithVowel: Bool {
        switch self {
        case .alien:
            return true
        default:
            return false
        }
    }
}

enum CharacterAction: String, CaseIterable, Hashable, Codable {
    case smiling, sitting, eating, drinking, walking, shopping, studying, working, relaxing, fighting, crying
    static var `default`: Self {
        .drinking
    }
}

enum CharacterLocation: String, CaseIterable, Hashable, Codable {
    case park, mall, museum, city, desert, forest, space
    static var `default`: Self {
        .park
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
        let prefix = characterOption.startsWithVowel ? "An" : "A"
        return "\(prefix) \(characterOption.rawValue) that is \(characterAction.rawValue) in the \(characterLocation.rawValue)."
    }
}
