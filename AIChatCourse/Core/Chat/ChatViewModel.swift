//
//  ChatViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/16/25.
//

import SwiftUI

/// 聊天功能总入口（Facade）
/// - Note: 协议本身标 `@MainActor`，表示其方法默认在主线程调用；
///         如某些耗时操作想脱离主线程，可在实现体里再开 Task。
@MainActor
protocol ChatInteractor {
    
    // MARK: - 只读状态 --------------------------------------------------
    
    /// 当前登录用户信息（可能为空，取决于是否已登录）
    var currentUser: UserModel? { get }
    
    /// 鉴权信息（uid / token 等），由 AuthManager 提供
    var auth: UserAuthInfo? { get }
    
    // MARK: - 日志埋点 --------------------------------------------------
    
    /// 统一事件追踪入口（内部转调 LogManager）
    func trackEvent(event: LoggableEvent)
    
    // MARK: - 聊天消息流 & 读取状态 --------------------------------------
    
    /// 订阅指定 Chat 的实时消息流
    func streamChatMessages(chatId: String)
        -> AsyncThrowingStream<[ChatMessageModel], Error>
    
    /// 将指定消息标记为「已读」
    func markChatMessageAsSeen(
        chatId: String,
        messageId: String,
        userId: String
    ) async throws
    
    // MARK: - 聊天会话 CRUD --------------------------------------------
    
    /// 获取指定用户与头像的 Chat（如无则返回 nil）
    func getChat(
        userId: String,
        avatarId: String
    ) async throws -> ChatModel?
    
    /// 创建全新 Chat（首聊时调用）
    func createNewChat(chat: ChatModel) async throws
    
    /// 删除整条 Chat
    func deleteChat(chatId: String) async throws
    
    /// 举报聊天（会生成 ReportModel 并上传）
    func reportChat(chatId: String, userId: String) async throws
    
    // MARK: - 消息发送 --------------------------------------------------
    
    /// 向 chatId 追加一条新消息
    func addChatMessage(
        chatId: String,
        message: ChatMessageModel
    ) async throws
    
    /// 将现有聊天记录发送给 AI，大模型生成回复
    func generateText(
        chats: [AIChatModel]
    ) async throws -> AIChatModel
    
    // MARK: - 头像相关 --------------------------------------------------
    
    /// 获取头像详情（缓存优先，网络兜底）
    func getAvatar(id: String) async throws -> AvatarModel
    
    /// 将头像加入「最近使用」
    func addRecentAvatar(avatar: AvatarModel) async throws
    
    // MARK: - 鉴权工具 --------------------------------------------------
    
    /// 取当前用户 uid；取不到时抛错
    func getAuthId() throws -> String
}

extension CoreInteractor: ChatInteractor {}

@Observable
@MainActor
final class ChatViewModel {
    private let interactor: ChatInteractor
    
    private(set) var chatMessages: [ChatMessageModel] = []
    private(set) var currentUser: UserModel?
    private(set) var avatar: AvatarModel?
    private(set) var chat: ChatModel?
    private(set) var auth: UserAuthInfo?
    private(set) var isGeneratingResponse: Bool = false
    
    var textFieldText: String = ""
    var scrollPosition: String?
    var showAlert: AnyAppAlert?
    var showProfileModal: Bool = false
    var showChatSettings: AnyAppAlert?
    
    init(interactor: ChatInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Func
    func onMessageDidAppear(message: ChatMessageModel) {
        interactor.trackEvent(event: Event.sendMessageStart(chat: chat, avatar: avatar))
        Task {
            do {
                let uid = try interactor.getAuthId()
                let chatId = try getChatId()
                
                guard !message.hasBeenSeenBy(userId: uid) else {
                    return
                }
                
                try await interactor.markChatMessageAsSeen(chatId: chatId, messageId: message.id, userId: uid)
                
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.messageSeenFail(error: error))
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
    func messageIsDelayed(message: ChatMessageModel) -> Bool {
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
    
    func getChatId() throws -> String {
        guard let chat else {
            throw ChatViewError.noChat
        }
        
        return chat.id
    }
    
    func listenForChatMessage() async {
        interactor.trackEvent(event: Event.loadMessageStart)
        do {
            let chatId = try getChatId()
            
            for try await value in interactor.streamChatMessages(chatId: chatId) {
                chatMessages = value.sortedByKeyPath(keyPath: \.dateCreatedCalculated)
                scrollPosition = chatMessages.last?.id
            }
        } catch {
            interactor.trackEvent(event: Event.loadMessageFail(error: error))
        }
    }
    
    func loadChat(avatarId: String) async {
        interactor.trackEvent(event: Event.loadChatStart)
        do {
            let uid = try interactor.getAuthId()
            chat = try await interactor.getChat(userId: uid, avatarId: avatarId)
            interactor.trackEvent(event: Event.loadChatSuccess(chat: chat))
        } catch {
            interactor.trackEvent(event: Event.loadChatFail(error: error))
        }
    }
    
    func createNewChat(chatId: String, avatarId: String) async throws -> ChatModel {
        
        interactor.trackEvent(event: Event.createChatStart)
        let newChat = ChatModel.new(userId: chatId, avatarId: avatarId)
        try await interactor.createNewChat(chat: newChat)
        
        defer {
            Task {
                await listenForChatMessage()
            }
        }
        
        return newChat
    }
    
    func onViewFirstAppear(chat: ChatModel?) {
        self.currentUser = interactor.currentUser
        self.chat = chat
    }
    
    func loadAvatar(avatarId: String) async {
        interactor.trackEvent(event: Event.loadAvatarStart)
        do {
            let avatar = try await interactor.getAvatar(id: avatarId)
            interactor.trackEvent(event: Event.loadAvatarSuccess(avatar: avatar))
            self.avatar = avatar
            // 是否失败无所谓 数据统计类的
            try? await interactor.addRecentAvatar(avatar: avatar)
            
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func onSendMessagePressed(avatarId: String) {
        let content = textFieldText
        
        Task {
            do {
                // 获取用户ID
                let uid = try interactor.getAuthId()
                // 验证输入框文字
                try TextValidationHelper.checkIfTextIsValid(text: content)
                // 如果是 新的聊天则进行创建
                if chat == nil {
                    chat = try await createNewChat(chatId: uid, avatarId: avatarId)
                }
                
                guard let chat else {
                    throw ChatViewError.noChat
                }
                
                // 创建用户聊天
                let newMessage = AIChatModel(role: .user, content: content)
                let message = ChatMessageModel.newUserSendMessage(chatId: chat.id, userId: uid, message: newMessage)
                
                // 上传用户聊天
                try await interactor.addChatMessage(chatId: chat.id, message: message)
                interactor.trackEvent(event: Event.sendMessageSent(chat: chat, avatar: avatar, message: message))
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
                let response = try await interactor.generateText(chats: aiChats)
                
                // 创建AI回复信息
                let newAIMessage = ChatMessageModel.newAIMessage(chatId: chat.id, avatarId: avatarId, message: response)
                interactor.trackEvent(event: Event.sendMessageResponse(chat: chat, avatar: avatar, message: message))
                
                // 上传AI聊天
                try await interactor.addChatMessage(chatId: chat.id, message: newAIMessage)
                interactor.trackEvent(event: Event.sendMessageResponseSent(chat: chat, avatar: avatar, message: message))
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    func onChatSettingPressed(onDeleteChat: @escaping @MainActor () -> Void) {
        interactor.trackEvent(event: Event.chatSettingPressed)
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group(content: {
                        Button("Report User / Chat", role: .destructive) {
                            self.onReportChatPressed()
                        }
                        Button("Delete Chat", role: .destructive) {
                            self.onDeleteChatPressed(onChatDelete: onDeleteChat)
                        }
                    })
                )
            }
        )
    }
    
    func onReportChatPressed() {
        interactor.trackEvent(event: Event.reportChatStart)
        Task {
            do {
                let chatId = try getChatId()
                let uid = try interactor.getAuthId()
                try await interactor.reportChat(chatId: chatId, userId: uid)
                
                interactor.trackEvent(event: Event.reportChatSuccess)
                
                showAlert = AnyAppAlert(
                    title: "🚨 Reported 🚨",
                    subtitle: "We will review the chat shortly. you may leave the chat at any time. Thanks for bringing this to our attention!"
                )
                
            } catch {
                interactor.trackEvent(event: Event.reportChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    func onDeleteChatPressed(onChatDelete: @escaping @MainActor () -> Void) {
//        logManager.trackEvent(event: Event.deleteChatStart)
        Task {
            do {
                let chatId = try getChatId()
                try await interactor.deleteChat(chatId: chatId)
//                logManager.trackEvent(event: Event.deleteChatSuccess)
                onChatDelete()
            } catch {
                interactor.trackEvent(event: Event.deleteChatFail(error: error))
                showAlert = AnyAppAlert(
                    title: "Something went wrong",
                    subtitle: "Please check your internet connection and try again."
                )
            }
        }
    }
    
    func onAvatarImagePressed() {
        interactor.trackEvent(event: Event.avatarImagePressed(avatar: avatar))
        showProfileModal = true
    }
    
    func messageIsCurrentUser(message: ChatMessageModel) -> Bool {
        message.authorId == interactor.auth?.uid
    }
    
    func onProfileModalXmarkPressed() {
        showProfileModal = false
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
            case .loadAvatarFail, .messageSeenFail, .reportChatFail, .deleteChatFail:
                return .severe
            case .loadChatFail, .sendMessageFail, .loadMessageFail:
                return .warning
            default:
                return .analytic
            }
        }
        
    }
    
}
