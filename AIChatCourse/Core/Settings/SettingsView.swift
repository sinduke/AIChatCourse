//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AppState.self) private var appState
    @Environment(ChatManager.self) private var chatManager
    @Environment(LogManager.self) private var logManager
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = false
    @State private var showCreateAccountView: Bool = false
    
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchasesSection
                applicationSection
            }
            .sheet(isPresented: $showCreateAccountView, onDismiss: {
                setAnonymousAccountStatus()
            }, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .navigationTitle("Settings")
            .screenAppearAnalytics(name: "SettingsView")
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    // MARK: -- Enum
    enum Event: LoggableEvent {

        case onSignOutStart
        case onSignOutSuccess
        case onSignOutFail(error: Error)

        case onDeleteAccountStart
        case onDeleteAccountSuccess
        case onDeleteAccountFail(error: Error)

        case onCreateAccountPressed

        var eventName: String {
            switch self {
            case .onSignOutStart: return "SettingsView_SignOut_Start"
            case .onSignOutSuccess: return "SettingsView_SignOut_Success"
            case .onSignOutFail: return "SettingsView_SignOut_Fail"

            case .onDeleteAccountStart: return "SettingsView_DeleteAccount_Start"
            case .onDeleteAccountSuccess: return "SettingsView_DeleteAccount_Success"
            case .onDeleteAccountFail: return "SettingsView_DeleteAccount_Fail"

            case .onCreateAccountPressed: return "SettingsView_CreateAccount_Pressed"
            }
        }

        var parameters: [String: Any]? {
            switch self {
            case .onSignOutFail(let error), .onDeleteAccountFail(let error): return error.eventParameters
            default: return nil
            }
        }

        var type: LogType {
            switch self {
            case .onSignOutFail, .onDeleteAccountFail: return .severe
            default: return .analytic
            }
        }
        
    }
    // MARK: -- View
    private var applicationSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("version".capitalized)
                Spacer(minLength: 0)
                Text(Utilities.appVersion ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            HStack(spacing: 8) {
                Text("build number".capitalized)
                Spacer(minLength: 0)
                Text(Utilities.buildNumber ?? "")
                    .foregroundStyle(.secondary)
            }
            .rowFormatting()
            .removeListRowFormatting()
            
            Text("Contact us")
                .foregroundStyle(.blue)
            .rowFormatting()
            .anyButton(.highlight, action: {
                
            })
            .removeListRowFormatting()

        } header: {
            Text("Application")
        } footer: {
            Text("Create by Sinduke. \nLearn more at www.sinduke.com")
                .baselineOffset(6)
        }
    }
    
    private var purchasesSection: some View {
        Section {
            HStack(spacing: 8) {
                Text("Account status: \(isPremium ? "Premium".uppercased() : "Free".uppercased())")
                Spacer()
                if isPremium {
                    Text("manage".uppercased())
                        .badgeButton()
                }
            }
            .rowFormatting()
            .anyButton(.highlight, action: {
                
            })
            // 这个是否禁用需呀在anybutton的下方才会生效
            .disabled(!isPremium)
            .removeListRowFormatting()
        } header: {
            Text("Purchases")
        }
    }
    
    private var accountSection: some View {
        Section {
            
            if isAnonymousUser {
                Text("save & back-up account".capitalized)
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        onCreateAccountPressed()
                    })
                    .removeListRowFormatting()
            } else {
                Text("Sign out".capitalized)
                    .rowFormatting()
                    .anyButton(.highlight, action: {
                        onSignOutPressed()
                    })
                    .removeListRowFormatting()
            }
            
            Text("Delete account".capitalized)
                .foregroundStyle(.red)
                .rowFormatting()
                .anyButton(.highlight, action: {
                    onDeleteAccountPressed()
                })
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    // MARK: -- Funcation
    private func onReportChatPressed() {
        
    }
    
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    private func onSignOutPressed() {
        logManager.trackEvent(event: Event.onSignOutStart)
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await onDismissScreen()
                logManager.trackEvent(event: Event.onSignOutSuccess)
            } catch {
                logManager.trackEvent(event: Event.onSignOutFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onDismissScreen() async {
        dismiss()
        try? await Task.sleep(for: .seconds(1))
        appState.updateViewState(showTabBarView: false)
    }
    
    private func onCreateAccountPressed() {
        logManager.trackEvent(event: Event.onCreateAccountPressed)
        showCreateAccountView = true
    }
    
    private func onDeleteAccountPressed() {
        logManager.trackEvent(event: Event.onDeleteAccountStart)
        showAlert = AnyAppAlert(
            title: "Delete Account?",
            subtitle: "This action is permanent and cannot be undone. Your data will be delete from our server forever",
            buttons: {
                AnyView(
                    Button("Delete", role: .destructive, action: {
                        onDeleteAccountConfirmed()
                    })
                )
            }
        )
        
    }
    
    private func onDeleteAccountConfirmed() {
        Task {
            do {
                let uid = try authManager.getAuthId()
                async let deleteAuth: () = authManager.deleteAccount()
                async let deleteUser: () = userManager.deleteCurrentUser()
                async let deleteAvatars: () = avatarManager.removeAuthorIdFromAllAvatars(userId: uid)
                async let deleteChats: () = chatManager.deleteAllChatForDeleteUser(userId: uid)
                
                let (_, _, _, _) = await (try deleteAuth, try deleteUser, try deleteAvatars, try deleteChats)
                logManager.trackEvent(event: Event.onDeleteAccountSuccess)

                await onDismissScreen()
                
            } catch {
                logManager.trackEvent(event: Event.onDeleteAccountFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
}

fileprivate extension View {
    func rowFormatting() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.background)
    }
}

// MARK: -- Preview
#Preview("No Auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(services: MockUserServices(user: nil)))
        .previewEnvrionment()
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvrionment()
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .previewEnvrionment()
}
