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
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
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
        .onChange(of: appState.showTabBar, { _, showTabBar in
            if !showTabBar {
                Task {
                    await checkUserStatus()
                }
            }
        })
        /**
         简单理解这两项
         .environment(<#T##object: (Observable & AnyObject)?##(Observable & AnyObject)?#>) 这个中使用的是Class 类
         .environment(<#T##keyPath: WritableKeyPath<EnvironmentValues, V>##WritableKeyPath<EnvironmentValues, V>#>, <#T##value: V##V#>) 这个中使用的是Struct 结构体
         */
    }
    
    // MARK: -- Funcation
    private func checkUserStatus() async {
        if let user = authManager.auth {
            // 用户已经登录
            dLog("用户已经登录了: \(user.uid)")
            
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                dLog("Failed to login to auth for existing user \(error)")
                
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
            
        } else {
            // 用户尚未登录
            do {
                let result = try await authManager.signInAnonymously()
                dLog("DEFAULT: anonymous sign in success: \(result.user.uid)") // default = info
                
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                dLog(error)
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(UserManager(service: MockService(user: .mock)))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(service: MockService(user: nil)))
}
