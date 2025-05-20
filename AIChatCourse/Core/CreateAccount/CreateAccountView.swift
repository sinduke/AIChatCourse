//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @Environment(AuthManager.self) private var authManager
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
                Text(subTitle)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SignInWithAppleButtonView(
                type: .signIn,
                style: .black,
                cornerRadius: 10
            )
            .frame(height: 50)
            .anyButton(.press) {
                onSignInApplePressed()
            }
            
            Spacer()
        }
        .padding()
        .padding(.top)
    }
    
    // MARK: -- Funcation
    private func onSignInApplePressed() {
        Task {
            do {
                let result = try await authManager.signInWithApple()
                dLog("使用Apple登录成功!")
                onDidSignIn?(result.isNewUser)
                dismiss()
            } catch {
                dLog("使用Apple登录失败 \(error)")
            }
        }
    }
}

#Preview {
    CreateAccountView()
}
