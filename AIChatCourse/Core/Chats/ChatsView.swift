//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ChatsView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(AuthManager.self) private var authManager
    @Environment(LogManager.self) private var logManager
    
    @State private var chats: [ChatModel] = []
    @State private var recentAvatars: [AvatarModel] = []
    @State private var path: [NavigationPathOption] = []
    
    @State private var isLoadingChats: Bool = false
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                if !recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .screenAppearAnalytics(name: "Chats")
            .navigationDestinationForCoreModult(path: $path)
            .onAppear {
                loadRecentAvatars()
            }
            .task {
                await loadChats()
            }
        }
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
    
    // MARK: -- View
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(.circle)
                                    .frame(minHeight: 60)
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .anyButton {
                                onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden )
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
    
    private var chatsSection: some View {
        Section {
            if isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else if chats.isEmpty {
                Text("Your chat will appear here!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(chats) { chat in
                    ChatRowCellViewBuilder(
                        currentUserId: authManager.auth?.uid,
                        chat: chat) {
                            /// 特殊错误处理
                            try? await avatarManager.getAvatar(id: chat.avatarId)
                        } getLastChatMessage: {
                            try? await chatManager.getLastChatMessage(chatId: chat.id)
                        }
                        .anyButton(.highlight, action: {
                            onChatPressed(chat: chat)
                        })
                        .removeListRowFormatting()
                }
            }
        } header: {
            Text(chats.isEmpty ? "" : "Chats")
        }

    }
    
    // MARK: -- Funcation
    private func loadChats() async {
        logManager.trackEvent(event: Event.loadChatsStart)
        isLoadingChats = true
        defer {
            isLoadingChats = false
        }
        do {
            let uid = try authManager.getAuthId()
            chats = try await chatManager.getAllChat(userId: uid)
                .sortedByKeyPath(keyPath: \.dateModified, ascending: false)
            logManager.trackEvent(event: Event.loadChatsSuccess(chatsCount: chats.count))
        } catch {
            logManager.trackEvent(event: Event.loadChatsFail(error: error))
        }
    }
    
    private func loadRecentAvatars() {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            recentAvatars = try avatarManager.getRecentAvatars()
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatarCount: recentAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func onChatPressed(chat: ChatModel) {
        logManager.trackEvent(event: Event.chatPressed(chat: chat))
        path.append(.chat(avatarId: chat.avatarId, chat: chat))
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
}

#Preview("Default") {
    ChatsView()
        .previewEnvrionment()
}

#Preview("No Data") {
    ChatsView()
        .environment(AvatarManager(
                service: MockAvatarService(avatars: []),
                local: MockLocalAvatarPersistence(avatars: [])))
        .environment(ChatManager(
                service: MockChatService(chats: [])))
        .previewEnvrionment()
}

#Preview("慢加载") {
    ChatsView()
        .environment(ChatManager(service: MockChatService(delay: 5)))
        .previewEnvrionment()
}
