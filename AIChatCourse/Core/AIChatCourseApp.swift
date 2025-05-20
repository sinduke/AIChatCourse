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
            EnvironmentBuilderView {
                AppView()
            }
        }
    }
}

struct EnvironmentBuilderView<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .environment(AuthManager(service: FirebaseAuthService()))
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
