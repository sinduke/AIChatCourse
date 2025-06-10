//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(LogManager.self) private var logManager
    @Environment(\.dismiss) private var dismiss
    var title: String = "Create Account?"
    var subTitle: String = "Don't lost your data! Connect to an SSO provider to save your account"
    var onDidSignIn: ((_ isNewUser: Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text(subTitle)
                    .font(.body)
                    .lineLimit(4)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 50)
            .frame(maxWidth: 400)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .padding(.top)
        .screenAppearAnalytics(name: "CreateAccount")
    }
    
    // MARK: -- enum
    enum Event: LoggableEvent {
        case appleAuthStart
        case appleAuthSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthLoginSuccess(user: UserAuthInfo, isNewUser: Bool)
        case appleAuthFail(error: Error)
        
        var eventName: String {
            switch self {
            case .appleAuthStart: return "CreateAccount_AppleAuth_Start"
            case .appleAuthSuccess: return "CreateAccount_AppleAuth_Success"
            case .appleAuthLoginSuccess: return "CreateAccount_AppleAuth_LoginSuccess"
            case .appleAuthFail: return "CreateAccount_AppleAuth_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case
                    .appleAuthSuccess(user: let user, isNewUser: let isNewUser),
                    .appleAuthLoginSuccess(user: let user, isNewUser: let isNewUser):
                var dict = user.eventParameters
                dict["is_new_user"] = isNewUser
                
                return dict
            case .appleAuthFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .appleAuthFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
    // MARK: -- Funcation
    private func onSignInApplePressed() {
        logManager.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await authManager.signInWithApple()
                logManager.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                try await userManager.logIn(auth: result.user, isNewUser: result.isNewUser)
                logManager.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
    }
}

#Preview {
    CreateAccountView()
        .previewEnvrionment()
        .frame(maxHeight: 400)
        .frame(maxHeight: .infinity, alignment: .bottom)
}
