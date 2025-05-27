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
        .onAppear(
            perform: {
                logManager.identifyUser(
                    userId: "sinduke1122",
                    name: "sinduke",
                    email: "sinduke@outlook.com"
                )
                
                logManager.addUserProperties(dict: UserModel.mock.eventParameters, isHighPriority: false)
                
                logManager.trackEvent(event: Event.alpha)
                logManager.trackEvent(event: Event.beta)
                logManager.trackEvent(event: Event.gamma)
                logManager.trackEvent(event: Event.delta)
                
                let event = AnyLoggableEvent(
                    eventName: "MyNewEvent",
                    parameters: UserModel.mock.eventParameters,
                    type: .analytic
                )
                logManager.trackScreen(event: event)
                
                logManager.trackEvent(eventName: "AnotherEventIsHere")
                
        })
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
        case alpha, beta, gamma, delta
        
        var eventName: String {
            switch self {
            case .alpha:
                return "Event_Alpha"
            case .beta:
                return "Event_Beta"
            case .gamma:
                return "Event_Gamma"
            case .delta:
                return "Event_Delta"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .alpha, .beta:
                return [
                    "aaa": true,
                    "bbb": 123
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .alpha:
                return .info
            case .beta:
                return .analytic
            case .gamma:
                return .warning
            case .delta:
                return .severe
            }
        }
        
    }
    
    // MARK: -- Funcation
    private func checkUserStatus() async {
        if let user = authManager.auth {
            do {
                try await userManager.logIn(auth: user, isNewUser: false)
            } catch {
                try? await Task.sleep(for: .seconds(5))
                await checkUserStatus()
            }
            
        } else {
            do {
                let result = try await authManager.signInAnonymously()
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
        .environment(UserManager(services: MockUserServices(user: .mock)))
}

#Preview("AppView - Onboarding") {
    AppView(appState: AppState(showTabBar: false))
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
}
