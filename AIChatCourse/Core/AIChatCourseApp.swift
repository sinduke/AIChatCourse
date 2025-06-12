//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by sinduke on 5/14/25.
//

import SwiftUI

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.container)
                .environment(delegate.dependencies.abTestManager)
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
                .environment(delegate.dependencies.pushManager)
        }
    }
}

/**
 struct EnvironmentBuilderView<Content: View>: View {
     
     @State private var authManager = AuthManager(service: FirebaseAuthService())
     @State private var usermanager = UserManager(services: ProductUserServices())
     
     @ViewBuilder var content: () -> Content
     var body: some View {
         content()
             .environment(authManager)
             .environment(usermanager)
     }
 }
 */

extension View {
    
    // 相同的环境会出现覆盖的情况。靠近self的优先级更高
    func previewEnvrionment(isSignedIn: Bool = true) -> some View {
        self
            .environment(DevPreview.shared.container)
            .environment(ABTestManager(service: MockABTestsService()))
            .environment(AIManager(service: MockAIService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AppState())
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: [ ]))
            .environment(PushManager())
    }
    /**
     根据这个注释内容。之后的代码可以这样写Preview
     
     逻辑就是尽管previewEnvrionment已经有environment(AvatarManager(service: MockAvatarService(delay: 1, showError: true)))的同名环境 但是新添加的这个测试优先级高于previewEnvrionment
     #Preview("预览注解") {
         ProfileView()
             .environment(AvatarManager(service: MockAvatarService(delay: 1, showError: true)))
             .previewEnvrionment()
     }
     */
}

@MainActor
class DevPreview {
    static let shared = DevPreview()
    
    /// 由于Shared单例了DevPreview 所以需要计算属性 每次都更新container 否则有多个Preview同时渲染的时候会出现未知错误
    var container: DependencyContainer {
        let container = DependencyContainer()
        container.register(AuthManager.self, service: authManager)
        container.register(UserManager.self, service: userManager)
        container.register(AIManager.self, service: aiManager)
        container.register(AvatarManager.self, service: avatarManager)
        container.register(ChatManager.self, service: chatManager)
        container.register(LogManager.self, service: logManager)
        container.register(PushManager.self, service: pushManager)
        container.register(ABTestManager.self, service: abTestManager)
        
        return container
    }
    
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    let pushManager: PushManager
    let abTestManager: ABTestManager
    
    init(isSignedIn: Bool = true) {
        self.authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
        self.userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
        self.aiManager = AIManager(service: MockAIService())
        self.avatarManager = AvatarManager(service: MockAvatarService())
        self.chatManager = ChatManager(service: MockChatService())
        self.logManager = LogManager(services: [ ])
        self.pushManager = PushManager()
        self.abTestManager = ABTestManager(service: MockABTestsService())
        
    }
}
