//
//  CoreInteractor.swift
//  AIChatCourse
//
//  Created by sinduke on 6/13/25.
//

import SwiftUI

@MainActor
struct CoreInteractor {
    // MARK: -- Config
    private let authManager: AuthManager
    private let userManager: UserManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let chatManager: ChatManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    // MARK: -- Init
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.userManager = container.resolve(UserManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.chatManager = container.resolve(ChatManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
    
    // MARK: -- AuthManager
    var auth: UserAuthInfo? {
        authManager.auth
    }
    
    var activeTests: ActiveABTests {
        abTestManager.activeTests
    }
    
    var createAccountTest: ActiveABTests {
        abTestManager.activeTests
    }
    
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func signInAnonymously() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInAnonymously()
    }
    
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool) {
        try await authManager.signInWithApple()
    }
    
    func deleteAccount() async throws {
        try await authManager.deleteAccount()
    }
    
    // MARK: -- UserManager
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws {
        try await userManager.logIn(auth: auth, isNewUser: isNewUser)
    }
    
    func addCurrentUserListener(userId: String) {
        userManager.addCurrentUserListener(userId: userId)
    }
    
    func makeOnBoardingCompleteForCurrentUser(profileColorHex: String) async throws {
        try await userManager.makeOnBoardingCompleteForCurrentUser(profileColorHex: profileColorHex)
    }
    
    func deleteCurrentUser() async throws {
        try await userManager.deleteCurrentUser()
    }
    
    // MARK: -- AIManager
    func generateImage(input: String) async throws -> UIImage {
        try await aiManager.generateImage(input: input)
    }
    
    func generateText(chats: [AIChatModel]) async throws -> AIChatModel {
        try await aiManager.generateText(chats: chats)
    }
    
    // MARK: -- AvatarManager
    func addRecentAvatar(avatar: AvatarModel) async throws {
        try await avatarManager.addRecentAvatar(avatar: avatar)
    }
    
    func getRecentAvatars() throws -> [AvatarModel] {
        try avatarManager.getRecentAvatars()
    }
    
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws {
        try await avatarManager.createAvatar(avatar: avatar, image: image)
    }
    
    func getFeaturedAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getFeaturedAvatars()
    }
    
    func getPopularAvatars() async throws -> [AvatarModel] {
        try await avatarManager.getPopularAvatars()
    }
    
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForCategory(category: category)
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuth(userId: userId)
    }
    
    func getAvatar(id: String) async throws -> AvatarModel {
        try await avatarManager.getAvatar(id: id)
    }
    
    func removeAuthorIdFromAllAvatars(userId: String) async throws {
        try await avatarManager.removeAuthorIdFromAllAvatars(userId: userId)
    }
    
    func incrementAvatarClickCount(avatarId: String) async throws {
        try await avatarManager.removeAuthorIdFromAllAvatars(userId: avatarId)
    }
    
    // MARK: -- ChatManager
    func createNewChat(chat: ChatModel) async throws {
        try await chatManager.createNewChat(chat: chat)
    }
    
    func getChat(userId: String, avatarId: String) async throws -> ChatModel? {
        try await chatManager.getChat(userId: userId, avatarId: avatarId)
    }
    
    func addChatMessage(chatId: String, message: ChatMessageModel) async throws {
        try await chatManager.addChatMessage(chatId: chatId, message: message)
    }
    
    func streamChatMessages(chatId: String) -> AsyncThrowingStream<[ChatMessageModel], Error> {
        chatManager.streamChatMessages(chatId: chatId)
    }
    
    func getAllChat(userId: String) async throws -> [ChatModel] {
        try await chatManager.getAllChat(userId: userId)
    }
    
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel? {
        try await chatManager.getLastChatMessage(chatId: chatId)
    }
    
    func deleteChat(chatId: String) async throws {
        try await chatManager.deleteChat(chatId: chatId)
    }
    
    func deleteAllChatForDeleteUser(userId: String) async throws {
        try await chatManager.deleteAllChatForDeleteUser(userId: userId)
    }
    
    func reportChat(chatId: String, userId: String) async throws {
        try await chatManager.reportChat(chatId: chatId, userId: userId)
    }
    
    func markChatMessageAsSeen(chatId: String, messageId: String, userId: String) async throws {
        try await chatManager.markChatMessageAsSeen(chatId: chatId, messageId: messageId, userId: userId)
    }
    
    // MARK: -- LogManager
    func identifyUser(userId: String, name: String?, email: String?) {
        logManager.identifyUser(userId: userId, name: name, email: email)
    }
    
    func addUserProperties(dict: [String: Any], isHighPriority: Bool) {
        logManager.addUserProperties(dict: dict, isHighPriority: isHighPriority)
    }
    
    func deleteUserProfile() {
        logManager.deleteUserProfile()
    }
    // 第3层封装
    func trackEvent(eventName: String, parameters: [String: Any]? = nil, type: LogType = .analytic) {
        logManager.trackEvent(eventName: eventName, parameters: parameters, type: type)
    }
    // 第2层封装
    func trackEvent(event: AnyLoggableEvent) {
        logManager.trackEvent(event: event)
    }
    // 第1层封装
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func trackScreen(event: LoggableEvent) {
        logManager.trackScreen(event: event)
    }
    
    // MARK: -- PushManager
    func requestAuthorization() async throws -> Bool {
        try await pushManager.requestAuthorization()
    }
    
    func canRequestAuthorization() async -> Bool {
        await pushManager.canRequestAuthorization()
    }

    func schedulePushNotificationsForNextWeek() {
        pushManager.schedulePushNotificationsForNextWeek()
    }
    
    // MARK: -- ABTestManager
//    var activeTests: ActiveABTests {
//        abTestManager.activeTests
//    }
    
    // MARK: -- SharedFunction
    func signOut() async throws {
        try authManager.signOut()
        userManager.signOut()
    }
}
