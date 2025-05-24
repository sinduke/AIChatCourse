//
//  TextValidationHelper.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

struct TextValidationHelper {
    enum TextValidationError: LocalizedError {
        case notEnoughCharacters(min: Int), hasBadWords
        
        var errorDescription: String? {
            switch self {
            case .notEnoughCharacters(min: let min):
                "Plase add at least \(min) characters."
            case .hasBadWords:
                "Bad word detected. Plase rephrase your message."
            }
        }
    }

    static func checkIfTextIsValid(text: String, minimumCharacterContent: Int = 4) throws {

        guard text.count >= minimumCharacterContent else {
            throw TextValidationError.notEnoughCharacters(min: minimumCharacterContent)
        }
        
        let badWords: [String] = [
            "shit", "bitch", "ass"
        ]
        
        if badWords.contains(text.lowercased()) {
            throw TextValidationError.hasBadWords
        }
    }
}
