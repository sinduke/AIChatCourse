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
    @Environment(LogManager.self) private var logManager
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
        .screenAppearAnalytics(name: "AppView")
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
    
    enum Event: LoggableEvent {
        case existingAuthStar
        case existingAuthFail(error: Error)
        case anonAuthStart
        case anonAuthSuccess
        case anonAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .existingAuthStar: return "AppView_ExistingAuth"
            case .existingAuthFail: return "AppView_ExistingAuthFail"
            case .anonAuthStart: return "AppView_AnonAuthStart"
            case .anonAuthSuccess: return "AppView_AnonAuthSuccess"
            case .anonAuthFail: return "AppView_AnonAuthFail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .existingAuthFail(error: let error), .anonAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .existingAuthFail, .anonAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
    // MARK: -- Funcation
    private func checkUserStatus() async {
        if let user = authManager.auth {
            logManager.trackEvent(event: Event.existingAuthStar)
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                logManager.trackEvent(event: Event.existingAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
            
        } else {
            
            logManager.trackEvent(event: Event.anonAuthStart)
            
            do {
                let result = try await authManager.signInAnonymously()
                logManager.trackEvent(event: Event.anonAuthSuccess)
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
            } catch {
                logManager.trackEvent(event: Event.anonAuthFail(error: error))
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
        }
    }
}

#Preview("AppView - Tabbar") {
    AppView(appState: AppState(showTabBar: true))
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
