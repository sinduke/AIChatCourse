//
//  OpenAIService.swift
//  AIChatCourse
//
//  Created by sinduke on 5/23/25.
//

import SwiftUI
import OpenAI

private typealias ChatParam = ChatQuery.ChatCompletionMessageParam

struct OpenAIService: AIService {
    
    var openAI: OpenAI {
        OpenAI(
            configuration: .init(
                token: Keys.openaiKey,
                host: "api.gptsapi.net",
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
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        
        do {
            let messages = chats.compactMap({ $0.toOpenAIModel() })
            let query = ChatQuery(
                messages: messages,
                model: .gpt3_5Turbo,
                responseFormat: .text
            )

            let result = try await openAI.chats(query: query)

            guard
                let chat = result.choices.first?.message,
                let model = AIChatModel(chat: chat)
            else {
                throw OpenAIError.invalidResponse
            }

//            dLog("✅ Return Message:")
//            dLog(chat.content ?? "❓未知OpenAI数据")
            
            return model

        } catch {
            print("❌ OpenAI 请求失败")
            print("🔹 错误类型: \(type(of: error))")
            print("🔹 错误描述: \(error.localizedDescription)")

            if let decodingError = error as? DecodingError {
                // 详细打印 JSON 解码错误类型
                switch decodingError {
                case .dataCorrupted(let context):
                    print("🔸 数据损坏: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("🔸 缺少键: \(key.stringValue) – \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("🔸 类型不匹配: \(type) – \(context.debugDescription)")
                case .valueNotFound(let value, let context):
                    print("🔸 值缺失: \(value) – \(context.debugDescription)")
                @unknown default:
                    print("🔸 未知 JSON 解码错误")
                }
            }

            throw error // 可选：向上传递错误
        }
    }
    
    enum OpenAIError: LocalizedError {
        case invalidResponse
        case invalidRequest
    }
    
}

struct AIChatModel: Codable {
    let role: AIChatRole
    let content: String
    
    init(role: AIChatRole, content: String) {
        self.role = role
        self.content = content
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
    }
    
    var eventParameters: [String: Any] {
        let dict: [String: Any?] = [
            "aichat_\(CodingKeys.role.rawValue)": role.rawValue,
            "aichat_\(CodingKeys.content.rawValue)": content
        ]
        // 返回把Nil丢弃之后的值
        return dict.compactMapValues({ $0 })
    }
    
    init?(chat: ChatResult.Choice.Message) {
        guard let roleEnum = ChatQuery.ChatCompletionMessageParam.Role(rawValue: chat.role),
              let content = chat.content else {
            return nil
        }
        
        self.role = AIChatRole(role: roleEnum)
        self.content = content
    }
    
    fileprivate func toOpenAIModel() -> ChatParam? {
        switch role {
        case .system:
            return ChatParam.system(ChatParam.SystemMessageParam(content: content))
        case .developer:
            return ChatParam.developer(ChatParam.DeveloperMessageParam(content: content))
        case .user:
            return ChatParam.user(ChatParam.UserMessageParam(content: .string(content)))
        case .assistant:
            return ChatParam.assistant(ChatParam.AssistantMessageParam(content: content))
        case .tool:
            return nil
        }
    }
    
}

enum AIChatRole: String, Codable {
    case system, developer, user, assistant, tool
    
    init(role: ChatQuery.ChatCompletionMessageParam.Role) {
        switch role {
        case .system:
            self = .system
        case .developer:
            self = .developer
        case .user:
            self = .user
        case .assistant:
            self = .assistant
        case .tool:
            self = .tool
        }
    }
    
    var openAIRole: ChatQuery.ChatCompletionMessageParam.Role {
        switch self {
        case .system:
            return .system
        case .developer:
            return .developer
        case .user:
            return .user
        case .assistant:
            return .assistant
        case .tool:
            return .tool
        }
    }
}
