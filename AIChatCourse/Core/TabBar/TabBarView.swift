//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct TabBarView: View {
    @Environment(DependencyContainer.self) private var container
    var body: some View {
        
        TabView {
            ExploreView(
                viewModel: ExploreViewModel(container: container)
            )
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
            ChatsView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
            ProfileView(
                viewmodel: ProfileViewModel(
                    container: container
                )
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
    }
}

#Preview {
    TabBarView()
        .previewEnvrionment()
}
