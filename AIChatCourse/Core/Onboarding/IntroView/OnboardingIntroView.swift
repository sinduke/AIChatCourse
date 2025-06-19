//
//  OnboardingIntroView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct OnboardingIntroView: View {
    
    @Environment(ABTestManager.self) private var abTestManager
    
    var body: some View {
        VStack {
            Group {
                Text("Make your own ")
                +
                Text("avatars ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("and chatwith them! \n\n Have ")
                +
                Text("real conversations ")
                    .foregroundStyle(.accent)
                    .fontWeight(.semibold)
                +
                Text("with Al generated responses.")
            }
            .baselineOffset(6)
            .frame(maxHeight: .infinity)
            .padding(24)
            .minimumScaleFactor(0.5)
            NavigationLink {
                if abTestManager.activeTests.onBoardingCommunityTest {
                    OnboardingCommunityView()
                } else {
                    OnboardingColorView()
                }
            } label: {
                Text("Continue")
                    .callToActionButton()
            }

        }
        .screenAppearAnalytics(name: "OnboardingIntroView")
        .font(.title3)
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        OnboardingIntroView()
    }
    .previewEnvrionment()
}

#Preview("OnBCommunityTest") {
    NavigationStack {
        OnboardingIntroView()
    }
    .environment(ABTestManager(service: MockABTestsService(onBoardingCommunityTest: true)))
    .previewEnvrionment()
}
