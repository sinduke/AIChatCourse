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
//            EnvironmentBuilderView {
//                AppView()
//            }
            AppView()
                .environment(delegate.dependencies.aiManager)
                .environment(delegate.dependencies.avatarManager)
                .environment(delegate.dependencies.authManager)
                .environment(delegate.dependencies.userManager)
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
        FirebaseApp.configure()
        dependencies = Dependencies()
        
        return true
    }
}

@MainActor
struct Dependencies {
    let authManager: AuthManager
    let userManager: UserManager
    let aiManager: AIManager
    let avatarManager: AvatarManager
    
    init() {
        authManager = AuthManager(service: FirebaseAuthService())
        userManager = UserManager(services: ProductUserServices())
        aiManager = AIManager(service: OpenAIService())
        avatarManager = AvatarManager(service: FirebaseAvatarService())
    }
    
}
