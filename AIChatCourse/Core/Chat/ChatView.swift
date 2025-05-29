//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    @Environment(ChatManager.self) private var chatManager
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var chatMessages: [ChatMessageModel] = []
    @State private var currentUser: UserModel?
    @State private var avatar: AvatarModel?
    @State private var textFieldText: String = ""
    @State var chat: ChatModel?
    
    @State private var showChatSettings: AnyAppAlert?
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    @State private var isGeneratingResponse: Bool = false
    
    var avatarId: String = AvatarModel.mock.avatarId
    
    // MARK: -- Body
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .foregroundStyle(.accent)
                        .anyButton {
                            onChatSettingPressed()
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
        .task {
            // loadHistoryMessage
            await loadChat()
            await listenForChatMessage()
        }
        .onAppear {
            loadCurrentUser()
        }
    }
    
    // MARK: -- View
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    
                    if messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = message.authorId == authManager.auth?.uid
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .onAppear(perform: {
                        onMessageDidAppear(message: message)
                    })
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .scrollIndicators(.hidden)

        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something", text: $textFieldText)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onSendMessagePressed()
                    }
            })
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.background)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    
    // MARK: -- FuncOfView
    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                showProfileModal = false
            }
            .padding(40)
            .transition(.slide)
    }
    
    // MARK: -- Func
    private func onMessageDidAppear(message: ChatMessageModel) {
        logManager.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
                
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.messageSeenFail(error: error))
            }
        }
    }
    
    /// 判定「当前消息」与「上一条消息」之间是否 **存在超过 45 分钟的时间间隔**，
    /// 以此判断该消息是否应被视为「长时间停顿后的消息」。
    ///
    /// 逻辑说明：
    /// 1. 先在 `chatMessages` 数组里找到当前消息的位置；
    /// 2. 若它本身是第一条消息，或找不到上一条消息，则直接返回 `false`；
    /// 3. 计算当前消息与上一条消息的时间差（单位：秒）；
    /// 4. 若时间差 **大于 45 分钟**（60 × 45 = 2 700 秒），返回 `true`，
    ///    否则返回 `false`。
    ///
    /// - Parameter message: 需要判断的这条 `ChatMessageModel`。
    /// - Returns:
    ///   `true` — 当前消息与上一条消息的时间间隔超过 45 分钟；
    ///   `false` — 无上一条消息可比较，或时间间隔未超过阈值。
    private func messageIsDelayed(message: ChatMessageModel) -> Bool {
        let currentMessageDate = message.dateCreatedCalculated
        // 找到当前消息在数组中的索引，并确认前一条消息存在(第一条或者越界都不算)
        guard let index = chatMessages.firstIndex(where: { $0.id == message.id }),
              chatMessages.indices.contains(index - 1) else {
            return false
        }
        
        let previousMessageDate = chatMessages[index - 1].dateCreatedCalculated
        let timeDiff = currentMessageDate.timeIntervalSince(previousMessageDate)
        
        // Thrshold = 60秒 * 45 = 45分钟
        let thrshold: TimeInterval = 60 * 45
        
        return timeDiff > thrshold
    }
    
    private func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        
        return chat.id
    }
    
    private func listenForChatMessage() async {
        logManager.trackEvent(event: Event.loadMessageStart)
        do {
            let chatId = try getChatId()
            
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            logManager.trackEvent(event: Event.loadMessageFail(error: error))
        }
    }
    
    private func loadChat() async {
        logManager.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            logManager.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            logManager.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    private func createNewChat(chatId: String) async throws -> ChatModel {
        
        logManager.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userId: chatId, avatarId: avatarId)
        try await chatManager.createNewChat(chat: newChat)
        
        defer {
            Task {
                await listenForChatMessage()
            }
        }
        
        return newChat
    }
    
    private func loadCurrentUser() {
        currentUser = userManager.currentUser
    }
    
    private func loadAvatar() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            logManager.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            self.avatar = avatar
            // 是否失败无所谓 数据统计类的
            try? await avatarManager.addRecentAvatar(avatar: avatar)
            
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func onSendMessagePressed() {
        let content = textFieldText
        
        Task {
            do {
                // 获取用户ID
                let uid = try authManager.getAuthId()
                // 验证输入框文字
                try TextValidationHelper.checkIfTextIsValid(text: content)
                // 如果是 新的聊天则进行创建
                if chat == nil {
                    chat = try await createNewChat(chatId: uid)
                }
                
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // 创建用户聊天
                let newMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserSendMessage(chatId: chat.id, userId: uid, message: newMessage)
                
                // 上传用户聊天
                try await chatManager.addChatMessage(chatId: chat.id, message: message)
                logManager.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
                textFieldText = ""
                
                // 创建AI回复内容
                isGeneratingResponse = true
                defer {
                    isGeneratingResponse = false
                }
                var aiChats = chatMessages.compactMap({ $0.content })
                
                if let avatarDescription = avatar?.characterDescription {
                    let systemMseeage = AIChatModel(
                        role: .system,
                        content: "You are a \(avatarDescription) with intelligence of an AI. We are having an very casual converstant. You are my friend."
                    )
                    aiChats.insert(systemMseeage, at: 0)
                }
                
                // Core 执行
                let response = try await aiManager.generateText(chats: aiChats)
                
                // 创建AI回复信息
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                logManager.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: message))
                
                // 上传AI聊天
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
                logManager.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: message))
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onChatSettingPressed() {
        logManager.trackEvent(event: Event.chatSettingPressed)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group(content: {
                        Button("Report User / Chat", role: .destructive) {
                            onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            onDeleteChatPressed()
                        }
                    })
                )
            }
        )
    }
    
    private func onReportChatPressed() {
        logManager.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let uid = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                
                logManager.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. you may leave the chat at any time. Thanks for bringing this to our attention!"
                )
                
            } catch {
                logManager.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
//        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
//                logManager.trackEvent(event: Event.deleteChatSuccess)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onAvatarImagePressed() {
        logManager.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        showProfileModal = true
    }
    
    // MARK: -- ENUM
    enum ChatViewError: Error {
        case noChat
    }
    
    enum Event: LoggableEvent {
        // 记录 -> 加载头像
        case loadAvatarStart
        case loadAvatarSuccess(avatar: AvatarModel?)
        case loadAvatarFail(error: Error)
        // 记录 -> 加载对话
        case loadChatStart
        case loadChatSuccess(chat: ChatModel?)
        case loadChatFail(error: Error)
        // 记录 -> 加载消息列表
        case loadMessageStart
        case loadMessageFail(error: Error)
        // 记录 -> 更新是否已读
        case messageSeenFail(error: Error)
        // 记录 -> 点击发送按钮
        case sendMessageStart(chat: ChatModel?, avatar: AvatarModel?)
        case sendMessageFail(error: Error)
        
        // 记录 -> 上传用户聊天
        case sendMessageSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        // 记录 -> 接收AI返回的数据
        case sendMessageResponse(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        // 记录 -> 上传AI的聊天内容
        case sendMessageResponseSent(chat: ChatModel?, avatar: AvatarModel?, message: ChatMessageModel)
        
        case createChatStart
        
        case chatSettingPressed
        
        case reportChatStart
        case reportChatSuccess
        case reportChatFail(error: Error)
        
        case deleteChatStart
        case deleteChatSuccess
        case deleteChatFail(error: Error)
        
        case avatarImagePressed(avatar: AvatarModel?)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart: return "ChatView_LoadAvatar_Start"
            case .loadAvatarSuccess: return "ChatView_LoadAvatar_Success"
            case .loadAvatarFail: return "ChatView_LoadAvatar_Fail"
                
            case .loadChatStart: return "ChatView_LoadChat_Start"
            case .loadChatSuccess: return "ChatView_LoadChat_Success"
            case .loadChatFail: return "ChatView_LoadChat_Fail"
                
            case .loadMessageStart: return "ChatView_LoadMessage_Start"
            case .loadMessageFail: return "ChatView_LoadMessage_Fail"
            
            case .messageSeenFail: return "ChatView_MessageSeen_Fail"
                
            case .sendMessageStart: return "ChatView_SendMessage_Start"
            case .sendMessageFail: return "ChatView_SendMessage_Fail"
                
            case .sendMessageSent: return "ChatView_SendMessage_Sent"
            case .sendMessageResponse: return "ChatView_SendMessage_Response"
            case .sendMessageResponseSent: return "ChatView_SendMessage_ResponseSent"
                
            case .createChatStart: return "ChatView_CreateChat_Start"
                
            case .chatSettingPressed: return "ChatView_ChatSettings_Pressed"
            
            case .reportChatStart: return "ChatView_ReportChat_Start"
            case .reportChatSuccess: return "ChatView_ReportChat_Success"
            case .reportChatFail: return "ChatView_ReportChat_Fail"
            
            case .deleteChatStart: return "ChatView_DeleteChat_Start"
            case .deleteChatSuccess: return "ChatView_DeleteChat_Success"
            case .deleteChatFail: return "ChatView_DeleteChat_Fail"
            
            case .avatarImagePressed: return "ChatView_AvatarImage_Pressed"
                
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(
                error: let error
            ), .loadChatFail(
                error: let error
            ), .loadMessageFail(
                error: let error
            ), .messageSeenFail(
                error: let error
            ), .sendMessageFail(
                error: let error
            ), .reportChatFail(
                error: let error
            ), .deleteChatFail(
                error: let error
            ):
                return error.eventParameters
            case .loadAvatarSuccess(avatar: let avatar), .avatarImagePressed(avatar: let avatar):
                return avatar?.eventParameters
                
            case .loadChatSuccess(chat: let chat):
                return chat?.eventParameters
                
            case .sendMessageStart(chat: let chat, avatar: let avatar):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                
                return dict
                
            case
                    .sendMessageSent(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponse(chat: let chat, avatar: let avatar, message: let message),
                    .sendMessageResponseSent(chat: let chat, avatar: let avatar, message: let message):
                var dict = chat?.eventParameters ?? [:]
                dict.merge(avatar?.eventParameters)
                dict.merge(message.eventParameters)
                
                return dict
                
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail, .loadMessageFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            case .loadChatFail, .sendMessageFail:
                return .warning
            default:
                return .analytic
            }
        }
        
    }
    
}

#Preview("Default") {
    NavigationStack {
        ChatView()
            .previewEnvrionment()
    }
}

#Preview("AI 延迟回复") {
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 10)))
            .previewEnvrionment()
    }
}

#Preview("AI 生成失败") {
    /**
     步骤:
     输入合法的(可验证的消息内容 点击发送 1秒后查看结果)
     */
    NavigationStack {
        ChatView()
            .environment(AIManager(service: MockAIService(delay: 1, showError: true)))
            .previewEnvrionment()
    }
}
