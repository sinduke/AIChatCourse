//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ExploreView: View {
    let avatar = AvatarModel.mock
    var body: some View {
        NavigationStack {
            HeroCellView(title: avatar.name, subTitle: avatar.characterDescription, imageName: avatar.profileImageName)
                .frame(height: 200)
                .navigationTitle("Explore")
        }
    }
}

#Preview {
    ExploreView()
}
