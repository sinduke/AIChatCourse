//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    @State var viewModel: CreateAccountViewModel
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
                viewModel.onSignInApplePressed { isNewUser in
                    onDidSignIn?(isNewUser)
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
        }
        .padding()
        .padding(.top)
        .screenAppearAnalytics(name: "CreateAccount")
    }
    
}

#Preview {
    CreateAccountView(
        viewModel: CreateAccountViewModel(
            interactor: CoreInteractor(
                container: DevPreview.shared.container
            )
        )
    )
    .previewEnvrionment()
    .frame(maxHeight: 400)
    .frame(maxHeight: .infinity, alignment: .bottom)
}
