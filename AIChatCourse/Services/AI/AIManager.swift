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
    private let service: AIservice
    
    init(service: AIservice) {
        self.service = service
    }
    
    func generateImage(input: String) async throws -> UIImage {
        try await service.generateImage(input: input)
    }
}
