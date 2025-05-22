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
    @Environment(AppState.self) private var appState
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
            .onAppear {
                setAnonymousAccountStatus()
            }
            .showCustomAlert(alert: $showAlert)
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
            Text("Create by swiftful thinking. \nLearn more at www.sinduke.com")
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
    private func setAnonymousAccountStatus() {
        isAnonymousUser = authManager.auth?.isAnonymous == true
    }
    
    private func onSignOutPressed() {
        Task {
            do {
                try authManager.signOut()
                userManager.signOut()
                await onDismissScreen()
            } catch {
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
        showCreateAccountView = true
    }
    
    private func onDeleteAccountPressed() {
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
                try await authManager.deleteAccount()
                try await userManager.deleteCurrentUser()
                await onDismissScreen()
            } catch {
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

#Preview("No Auth") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: nil)))
        .environment(UserManager(service: MockService()))
        .environment(AppState())
}

#Preview("Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: true))))
        .environment(UserManager(service: MockService(user: .mock)))
        .environment(AppState())
}

#Preview("Not Anonymous") {
    SettingsView()
        .environment(AuthManager(service: MockAuthService(user: UserAuthInfo.mock(isAnonymous: false))))
        .environment(UserManager(service: MockService(user: .mock)))
        .environment(AppState())
}
