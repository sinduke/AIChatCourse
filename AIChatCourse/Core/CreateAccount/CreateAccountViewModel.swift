//
//  CreateAccountViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/16/25.
//

import SwiftUI

@MainActor
protocol CreateAccountInteractor {
    func trackEvent(event: LoggableEvent)
    func signInWithApple() async throws -> (user: UserAuthInfo, isNewUser: Bool)
    func logIn(auth: UserAuthInfo, isNewUser: Bool) async throws
}

extension CoreInteractor: CreateAccountInteractor {}

@Observable
@MainActor
final class CreateAccountViewModel {
    private let interactor: CreateAccountInteractor
    
    init(interactor: CreateAccountInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Funcation
    func onSignInApplePressed(onDidSignInSuccessful: @escaping (_ isNewUser: Bool) -> Void) {
        interactor.trackEvent(event: Event.appleAuthStart)
        Task {
            do {
                let result = try await interactor.signInWithApple()
                interactor.trackEvent(event: Event.appleAuthSuccess(user: result.user, isNewUser: result.isNewUser))
                try await interactor.logIn(auth: result.user, isNewUser: result.isNewUser)
                interactor.trackEvent(event: Event.appleAuthLoginSuccess(user: result.user, isNewUser: result.isNewUser))
                
                onDidSignInSuccessful(result.isNewUser)
            } catch {
                interactor.trackEvent(event: Event.appleAuthFail(error: error))
            }
        }
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
    
}
