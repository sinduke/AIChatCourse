//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI
import FirebaseAuth

struct OnboardingCompletedView: View {
    @State private var isCompletingSetupProfile: Bool = false
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    var selectColor: Color = .orange
    @State private var showAlert: AnyAppAlert?

    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text("Setup complete".capitalized)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectColor)
            
            Text("We have set up your profile and you are ready to start chating.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: nil, content: {
            AsyncCallToActionButton(
                isLoading: isCompletingSetupProfile,
                title: "finish",
                action: onFinishButtonPressed
            )
        })
        .padding(16)
        .toolbar(.hidden, for: .navigationBar)
        .screenAppearAnalytics(name: "OnboardingCompletedView")
        .showCustomAlert(alert: $showAlert)
    }
    
    // MARK: -- Enum
    enum Event: LoggableEvent {
        case onFinishStart
        case onFinishSuccess(hex: String)
        case onFinishFail(error: Error)

        var eventName: String {
            switch self {
            case .onFinishStart: return "OnboardingCompletedView_Finish_Start"
            case .onFinishSuccess: return "OnboardingCompletedView_Finish_Success"
            case .onFinishFail: return "OnboardingCompletedView_Finish_Fail"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onFinishSuccess(let hex): return ["profile_color_hex": hex]
            case .onFinishFail(let error): return error.eventParameters
            default: return nil
            }
        }
        var type: LogType {
            switch self {
            case .onFinishFail: return .severe
            default: return .analytic
            }
        }
    }

    func onFinishButtonPressed() {
        logManager.trackEvent(event: Event.onFinishStart)
        isCompletingSetupProfile = true
        Task {
            do {
                let hex = selectColor.asHex()
                try await userManager.makeOnBoardingCompleteForCurrentUser(profileColorHex: hex)
                
                // dismiss screen
                isCompletingSetupProfile = false
                root.updateViewState(showTabBarView: true)
                logManager.trackEvent(event: Event.onFinishSuccess(hex: hex))
            } catch {  
                logManager.trackEvent(event: Event.onFinishFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
}

#Preview {
    OnboardingCompletedView(selectColor: .mint)
        .environment(AppState())
        .environment(UserManager(services: MockUserServices(user: nil)))
}
