//
//  TabBarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct TabBarView: View {
    var body: some View {
//        NavigationStack {
//            
////            .navigationBarHidden(true)
////            // iOS18特有的方法
////            .toolbarVisibility(.hidden, for: .navigationBar)
//            .toolbar(.hidden, for: .navigationBar)
//            .navigationTitle("Tabbar")
//        }

        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "eyes")
                }
           ChatsView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    TabBarView()
}
