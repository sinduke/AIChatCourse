//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct WelcomeView: View {
    @State var imageName: String = Constants.randomImage
    @State private var showSignInView: Bool = false
    @Environment(AppState.self) private var root
    @Environment(LogManager.self) private var logManager
    
    var body: some View {
        NavigationStack {
            VStack {
                ImageLoaderView(urlString: imageName)
                    .ignoresSafeArea()
                
                titleSection
                    .padding(.top, 24)
                
                ctaButtonSection
                    .padding(16)
                
                policySection
            }
            .screenAppearAnalytics(name: "WelcomeView")
            .sheet(
                isPresented: $showSignInView,
                content: {
                    CreateAccountView(
                        title: "Sign In",
                        subTitle: "Connect to existing account",
                        onDidSignIn: { isNewUser in
                            handingDidSignIn(isNewUser: isNewUser)
                        }
                    )
                    .presentationDetents([.medium])
            })
        }
    }
    
    // MARK: -- View
    private var titleSection: some View {
        VStack {
            Text("AI Chat 👍")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("TikTok @Sinduke")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtonSection: some View {
        VStack {
            // TO1DO: 这里理论上不能进行点击操作了 以后改成MVVM架构的时候修改(强迫症犯了 去掉警告⚠️)
            NavigationLink {
                OnboardingIntroView()
            } label: {
                Text("Get start".uppercased())
                    .callToActionButton()
            }
            Text("Already have an Account? Sign In")
                .underline()
                .font(.body)
                .padding(8)
                .onTapGesture {
                    onSignInPressed()
                }
        }
    }
    
    private var policySection: some View {
        HStack(spacing: 8) {
            Link(destination: URL(string: Constants.teamsOfServiceURLString)!) {
                Text("Teams of service")
            }
            Circle()
                .fill(.accent)
                .frame(width: 4)
            Link(destination: URL(string: Constants.privacyPolicyURLString)!) {
                Text("Privacy policy")
            }
        }
    }
    
    // MARK: -- Funcation
    private func onSignInPressed() {
        showSignInView = true
        logManager.trackEvent(event: Event.signInPressed)
    }
    
    private func handingDidSignIn(isNewUser: Bool) {
        logManager.trackEvent(event: Event.didSignIn(isNewUser: isNewUser))
        if isNewUser {
            // Do Nothing
        } else {
            root.updateViewState(showTabBarView: true)
        }
    }
    
    // MARK: -- Enum
    enum Event: LoggableEvent {
        case didSignIn(isNewUser: Bool)
        case signInPressed
        
        var eventName: String {
            switch self {
            case .didSignIn: return "WelcomeView_DidSignIn"
            case .signInPressed: return "WelcomeView_SignIn_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .didSignIn(isNewUser: let isNewUser): return ["is_new_user": isNewUser]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            default:
                return .analytic
            }
        }
        
    }
}

#Preview {
    WelcomeView()
}
