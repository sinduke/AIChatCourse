//
//  AppView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/14/25.
//

import SwiftUI

// tabbar - signed in
// onboarding - signed out

struct AppView: View {
    
    @Environment(\.authService) private var authService
    @State var appState: AppState = AppState()

    var body: some View {
        AppViewBuilder(
            showTabBar: appState.showTabBar,
            tabbarView: {
                TabBarView()
            },
            onboardingView: {
                WelcomeView()
            }
        )
        .environment(appState)
        .task {
            await checkUserStatus()
        }
        /**
         简单理解这两项
         .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) 这个中使用的是Class 类
         .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) 这个中使用的是Struct 结构体
         */
    }
    
    // MARK: -- Funcation
    private func checkUserStatus() async {
        if let user = authService.getAuthenticatedUser() {
            // 用户已经登录
            dLog("用户已经登录了: \(user.uid)")
        } else {
            // 用户尚未登录
            do {
                let result = try await authService.signInAnonymously()
                
                /**
                 dLog("ERROR: anonymous sign in success: \(result.user.uid)", .error)
                 dLog("INFO: anonymous sign in success: \(result.user.uid)", .info)
                 dLog("WARNING: anonymous sign in success: \(result.user.uid)", .warning)
                 */
                dLog("DEFAULT: anonymous sign in success: \(result.user.uid)") // default = info
            } catch {
                dLog(error)
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
}
