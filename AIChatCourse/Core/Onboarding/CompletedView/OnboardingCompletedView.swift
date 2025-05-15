//
//  OnboardingCompletedView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct OnboardingCompletedView: View {
    @Environment(AppState.self) private var root
    var body: some View {
        VStack {
            Text("onboarding completed".capitalized)
                .frame(maxHeight: .infinity)
            Button {
                onFinishButtonPressed()
            } label: {
                Text("finish".uppercased())
                    .callToActionButton()
            }
        }
        .padding(16)
    }
    func onFinishButtonPressed() {
        root.updateViewState(showTabBarView: true)
    }
}

#Preview {
    OnboardingCompletedView()
        .environment(AppState())
}
