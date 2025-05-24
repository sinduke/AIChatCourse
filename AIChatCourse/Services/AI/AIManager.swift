//
//  AIManager.swift
//  AIChatCourse
//
//  Created by sinduke on 5/22/25.
//

import SwiftUI

@MainActor
@Observable
class AIManager {
    private let service: AIService
    
    init(service: AIService) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
