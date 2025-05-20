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
            
            Text("YouTube @swiftfulThinking")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var ctaButtonSection: some View {
        VStack {
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
    }
    
    private func handingDidSignIn(isNewUser: Bool) {
        if isNewUser {
            // Do Nothing
        } else {
            root.updateViewState(showTabBarView: true)
        }
    }
    
}

#Preview {
    WelcomeView()
}
