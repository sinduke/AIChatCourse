//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @State private var isCompletingSetupProfile: Bool = false
    @Environment(AppState.self) private var root
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
            try? await Task.sleep(for: .seconds(3))
            isCompletingSetupProfile = false
            root.updateViewState(showTabBarView: true)
        }
    }
}

#Preview {
    OnboardingCompletedView(selectColor: .mint)
        .environment(AppState())
}
