//
//  WelcomeView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome")
                    .frame(maxHeight: .infinity)
                NavigationLink {
                    OnboardingCompletedView()
                } label: {
                    Text("Get start".uppercased())
                        .callToActionButton()
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    WelcomeView()
}
