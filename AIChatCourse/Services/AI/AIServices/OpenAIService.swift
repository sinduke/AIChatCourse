//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI
import OpenAI

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(
            configuration: .init(
                token: Keys.openaiKey,
                host: "api.gptsapi.net"
            )
        )
    }
    
    func generateImage(input: String) async throws -> UIImage {
        
        let query = ImagesQuery(
            prompt: input,
            model: .dall_e_3,
            n: 1,
            quality: .hd,
            responseFormat: .b64_json,
            size: ._1024,
            style: .natural,
            user: nil
        )
        
        let result = try await openAI.images(query: query)
        
        guard let b64Json = result.data.first?.b64Json,
              let data = Data(base64Encoded: b64Json),
              let image = UIImage(data: data) else {
            throw OpenAIError.invalidResponse
        }
        return image
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
    }
    
}
