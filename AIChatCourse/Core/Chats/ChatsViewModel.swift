//
//  ChatsViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/16/25.
//

import SwiftUI

// TODO: 这里后续优化 不必要把所有的都放到主线程
@MainActor
protocol ChatsInteractor {
    var auth: UserAuthInfo? { get }
    func getRecentAvatars() throws -> [AvatarModel]
    func trackEvent(event: LoggableEvent)
    func getAuthId() throws -> String
    func getAllChat(userId: String) async throws -> [ChatModel]
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatsInteractor {}

@Observable
@MainActor
final class ChatsViewModel {
    private let interactor: ChatsInteractor
    
    private(set) var chats: [ChatModel] = []
    private(set) var recentAvatars: [AvatarModel] = []
    private(set) var isLoadingChats: Bool = false
    
    var path: [NavigationPathOption] = []
    
    var auth: UserAuthInfo? {
        interactor.auth
    }
    
    init(interactor: ChatsInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Funcation
    func loadChats() async {
        interactor.trackEvent(event: Event.loadChatsStart)
        isLoadingChats = true
        defer {
            isLoadingChats = false
        }
        do {
            let uid = try interactor.getAuthId()
            chats = try await interactor.getAllChat(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            interactor.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            interactor.trackEvent(event: Event.loadChatsFail(error: error))
        }
    }
    
    func loadRecentAvatars() {
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            recentAvatars = try interactor.getRecentAvatars()
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatarCount: recentAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func onChatPressed(chat: ChatModel) {
        interactor.trackEvent(event: Event.chatPressed(chat: chat))
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await interactor.getLastChatMessage(chatId: chatId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await interactor.getAvatar(id: id)
    }
    
    // MARK: -- enum
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(avatarCount: Int)
        case loadAvatarFail(error: Error)
        
        case loadChatsStart
        case loadChatsSuccess(chatsCount: Int)
        case loadChatsFail(error: Error)
        
        case chatPressed(chat: ChatModel)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart: return "ChatsView_LoadAvatar_Start"
            case .loadAvatarSuccess: return "ChatsView_LoadAvatar_Success"
            case .loadAvatarFail: return "ChatsView_LoadAvatar_Fail"
            
            case .loadChatsStart: return "ChatsView_LoadChats_Start"
            case .loadChatsSuccess: return "ChatsView_LoadChats_Success"
            case .loadChatsFail: return "ChatsView_LoadChats_Fail"
            
            case .chatPressed: return "ChatsView_Chat_Pressed"
            case .avatarPressed: return "ChatsView_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(avatarCount: let avatarCount):
                return [
                    "avatars_count": avatarCount
                ]
            case .loadChatsSuccess(chatsCount: let chatsCount):
                return [
                    "chats_count": chatsCount
                ]
            case .loadAvatarFail(error: let error), .loadChatsFail(error: let error):
                return error.eventParameters
            case .chatPressed(chat: let chat):
                return chat.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail, .loadChatsFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
}
