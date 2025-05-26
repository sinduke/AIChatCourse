//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatView: View {
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
            .keyboardType(.alphabet)
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
        Task {
            do {
                let uid = try authManager.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
                
            } catch {
                dLog("Faild to mark message as seen. Error: \(error)")
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
        do {
            let chatId = try getChatId()
            
            for try await value in chatManager.streamChatMessages(chatId: chatId) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            dLog("Faild to attach chat message listener.")
        }
    }
    
    private func loadChat() async {
        do {
            let uid = try authManager.getAuthId()
            chat = try await chatManager.getChat(userId: uid, avatarId: avatarId)
            dLog("Success Loading Chat.")
        } catch {
            dLog("Error Loading Chat!", .error)
        }
    }
    
    private func createNewChat(chatId: String) async throws -> ChatModel {
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
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            // 是否失败无所谓 数据统计类的
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            dLog("Error loading avatar: \(error)")
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
                
                // 上传AI聊天
                try await chatManager.addChatMessage(chatId: chat.id, message: newAIMessage)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onChatSettingPressed() {
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
        Task {
            do {
                let chatId = try getChatId()
                let uid = try authManager.getAuthId()
                try await chatManager.reportChat(chatId: chatId, userId: uid)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. you may leave the chat at any time. Thanks for bringing this to our attention!"
                )
                
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onDeleteChatPressed() {
        Task {
            do {
                let chatId = try getChatId()
                try await chatManager.deleteChat(chatId: chatId)
                
                dismiss()
            } catch {
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    private func onAvatarImagePressed() {
        showProfileModal = true
    }
    
    // MARK: -- ENUM
    enum ChatViewError: Error {
        case noChat
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
