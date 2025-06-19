//
//  OnboardingCommunityView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct OnboardingCommunityView: View {
    var body: some View {
        VStack {
            
            VStack(spacing: 40.0) {
                ImageLoaderView()
                    .frame(width: 150, height: 150)
                    .clipShape(.circle)
                
                Group {
                    Text("Join our community with over ")
                    +
                    Text("1000+ ")
                        .foregroundStyle(.accent)
                        .fontWeight(.semibold)
                    +
                    Text("custom avatars! \n\n Ask them questions or have a casual conversation! ")
                }
                .baselineOffset(6)
                .padding(24)
            }
            .frame(maxHeight: .infinity)
            .minimumScaleFactor(0.5)
            NavigationLink {
                OnboardingColorView()
            } label: {
                Text("Continue")
                    .callToActionButton()
            }

        }
        .screenAppearAnalytics(name: "OnboardingCommunityView")
        .font(.title3)
        .padding(24)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        OnboardingCommunityView()
    }
    .previewEnvrionment()
}
