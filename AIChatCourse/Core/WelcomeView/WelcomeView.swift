//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct WelcomeView: View {
    @State var imageName: String = Constants.randomImage
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
        }
    }
    
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
                    print("点击了按钮")
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
    
}

#Preview {
    WelcomeView()
}
