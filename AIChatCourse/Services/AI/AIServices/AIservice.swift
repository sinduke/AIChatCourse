//
//  AIservice.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI

protocol AIService: Sendable {
    func generateImage(input: String) async throws -> UIImage
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel
}
