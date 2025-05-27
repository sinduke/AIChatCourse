//
//  AIChatCourseApp.swift
//  AIChatCourse
//
//  Created by sinduke on 5/14/25.
//

import SwiftUI
import Firebase

@main
struct AIChatCourseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
                .environment(delegate.dependencies.chatManager)
                .environment(delegate.dependencies.logManager)
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

class AppDelegate: NSObject, UIApplicationDelegate {
    
    var dependencies: Dependencies!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        let config: BuildConfiguration
        
        #if MOCK
        config = .mock(isSignedIn: true)
        #elseif DEV
        config = .dev
        #else
        config = .prod
        #endif
        
        config.config()
        dependencies = Dependencies(config: config)
        
        return true
    }
}

enum BuildConfiguration {
    case mock(isSignedIn: Bool), dev, prod
    
    func config() {
        switch self {
//        case .mock(let isSignedIn):
        case .mock:
            break
        case .dev:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Dev", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        case .prod:
            let plist = Bundle.main.path(forResource: "GoogleService-Info-Prod", ofType: "plist")!
            let options = FirebaseOptions(contentsOfFile: plist)!
            FirebaseApp.configure(options: options)
        }
    }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    let chatManager: ChatManager
    let logManager: LogManager
    
    init(config: BuildConfiguration) {
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil))
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil))
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            logManager = LogManager(services: [
                ConsoleService(printParameters: false)
                // mock中不添加分析
            ])
        case .dev:
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductUserServices())
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            logManager = LogManager(services: [
//                ConsoleService()
                ConsoleService(), FirebaseAnalyticsService()
            ])
        case .prod:
            authManager = AuthManager(service: FirebaseAuthService())
            userManager = UserManager(services: ProductUserServices())
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            logManager = LogManager(services: [
                // prod中不添加打印(oslog)
                FirebaseAnalyticsService()
            ])
        }
    }
}

extension View {
    
    // 相同的环境会出现覆盖的情况。靠近self的优先级更高
    func previewEnvrionment(isSignedIn: Bool = true) -> some View {
        self
            .environment(AIManager(service: MockAIService()))
            .environment(UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil)))
            .environment(AppState())
            .environment(AvatarManager(service: MockAvatarService()))
            .environment(AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil)))
            .environment(ChatManager(service: MockChatService()))
            .environment(LogManager(services: [ ]))
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
