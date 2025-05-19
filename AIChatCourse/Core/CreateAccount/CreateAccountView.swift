//
//  CreateAccountView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAccountView: View {
    
    var title: String = "Create Account?"
    var subTitle: String = "Don't lost your data! Connect to an SSO provider to save your account"
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
                
            }
            
            Spacer()
        }
        .padding()
        .padding(.top)
    }
}

#Preview {
    CreateAccountView()
}
