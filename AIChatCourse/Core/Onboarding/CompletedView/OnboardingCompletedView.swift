//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI
import FirebaseAuth

struct OnboardingCompletedView: View {
    @State private var isCompletingSetupProfile: Bool = false
    @Environment(AppState.self) private var root
    @Environment(UserManager.self) private var userManager
    var selectColor: Color = .orange
    var body: some View {
        VStack(alignment: .leading, spacing: 12.0) {
            Text("Setup complete".capitalized)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundStyle(selectColor)
            
            Text("We have set up your profile and you are ready to start chating.")
                .font(.title)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
        .safeAreaInset(edge: .bottom, alignment: .center, spacing: nil, content: {
            AsyncCallToActionButton(
                isLoading: isCompletingSetupProfile,
                title: "finish",
                action: onFinishButtonPressed
            )
        })
        .padding(16)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    func onFinishButtonPressed() {
        isCompletingSetupProfile = true
        Task {
            let hex = selectColor.asHex()
            try await userManager.makeOnBoardingCompleteForCurrentUser(profileColorHex: hex)
            
            // dismiss screen
            isCompletingSetupProfile = false
            root.updateViewState(showTabBarView: true)
        }
    }
    
}

#Preview {
    OnboardingCompletedView(selectColor: .mint)
        .environment(AppState())
        .environment(UserManager(services: MockUserServices(user: nil)))
}
