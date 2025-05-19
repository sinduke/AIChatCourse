//
//  SettingsView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState
    @State private var isPremium: Bool = false
    @State private var isAnonymousUser: Bool = true
    @State private var showCreateAccountView: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                accountSection
                purchasesSection
                applicationSection
            }
            .sheet(isPresented: $showCreateAccountView, content: {
                CreateAccountView()
                    .presentationDetents([.medium])
            })
            .navigationTitle("Settings")
        }
    }
    
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
                    onSignOutPressed()
                })
                .removeListRowFormatting()
        } header: {
            Text("Account")
        }
    }
    
    private func onSignOutPressed() {
        dismiss()
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            appState.updateViewState(showTabBarView: false)
        }
    }
    
    private func onCreateAccountPressed() {
        showCreateAccountView = true
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

#Preview {
    SettingsView()
        .environment(AppState())
}
