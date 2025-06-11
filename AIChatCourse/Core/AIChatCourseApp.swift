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
