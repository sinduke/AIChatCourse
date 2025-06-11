//
//  AppDelegate.swift
//  AIChatCourse
//
//  Created by sinduke on 5/31/25.
//

import SwiftUI
import Firebase

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
    let pushManager: PushManager
    let abTestManager: ABTestManager
    
    init(config: BuildConfiguration) {
        
        switch config {
        case .mock(isSignedIn: let isSignedIn):
            logManager = LogManager(services: [
                ConsoleService(printParameters: Constants.printLog)
                // mock中不添加分析
            ])
            authManager = AuthManager(service: MockAuthService(user: isSignedIn ? .mock() : nil), logManager: logManager)
            userManager = UserManager(services: MockUserServices(user: isSignedIn ? .mock : nil), logManager: logManager)
            aiManager = AIManager(service: MockAIService())
            avatarManager = AvatarManager(service: MockAvatarService(), local: MockLocalAvatarPersistence())
            chatManager = ChatManager(service: MockChatService())
            abTestManager = ABTestManager(service: MockABTestsService(), logManager: logManager)
            
        case .dev:
            logManager = LogManager(services: [
                // 日志开关(printParameters: 日志详情开关)
                ConsoleService(printParameters: Constants.printLog),
                FirebaseAnalyticsService(),
                MixPanelService(token: Keys.minPanelToken, loggingEnabled: false),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: MockABTestsService(), logManager: logManager)
            
        case .prod:
            logManager = LogManager(services: [
                // prod中不添加打印(oslog)
                // mixPanel记录的时候 Prod模式下不要打印
                FirebaseAnalyticsService(),
                MixPanelService(token: Keys.minPanelToken),
                FirebaseCrashlyticsService()
            ])
            authManager = AuthManager(service: FirebaseAuthService(), logManager: logManager)
            userManager = UserManager(services: ProductUserServices(), logManager: logManager)
            aiManager = AIManager(service: OpenAIService())
            avatarManager = AvatarManager(service: FirebaseAvatarService(), local: SwiftDataLocalAvatarPersistence())
            chatManager = ChatManager(service: FirebaseChatService())
            abTestManager = ABTestManager(service: MockABTestsService(), logManager: logManager)
        }
        pushManager = PushManager(logManager: logManager)
    }
}
