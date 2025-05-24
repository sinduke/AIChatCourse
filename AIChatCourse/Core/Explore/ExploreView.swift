//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    
//    @State private var featuredAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var categories: [CharacterOption] = CharacterOption.allCases
//    @State private var popularAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var popularAvatars: [AvatarModel] = []
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ProgressView()
                        .padding(40)
                        .frame(maxWidth: .infinity)
                        .removeListRowFormatting()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categoriesSection
                    popularSection
                }
                
            }
            .navigationTitle("Explore")
            .navigationDestinationForCoreModult(path: $path)
            .task {
                await loadFeaturedAvatar()
            }
            .task {
                await loadPopularAvatar()
            }
        }
    }
    // MARK: -- View
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
        } header: {
            Text("Featured Avatars")
        }
        .removeListRowFormatting()
    }
    
    private var categoriesSection: some View {
        Section {
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        
                        if let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName {
                            CategoryCellView(
                                title: category.rawValue.capitalized,
                                imageName: imageName
                            )
                            .scrollTargetLayout()
                            .anyButton(.highlight) {
                                onCategoryPressed(category: category, imageName: imageName)
                            }
                        }
                        
                    }
                }
            }
            .frame(height: 140)
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
        } header: {
            Text("Categories")
        }
        .removeListRowFormatting()
    }
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subTitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
            }
        } header: {
            Text("Popular")
        }
        .removeListRowFormatting()
    }
    
    // MARK: -- Funcation
    private func loadFeaturedAvatar() async {
        guard featuredAvatars.isEmpty else { return }
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            dLog("📌 Featured avatars: \(featuredAvatars.map(\.characterOption))")
        } catch {
            dLog("Error loading feature avatars: \(error)")
        }
    }
    
    private func loadPopularAvatar() async {
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            dLog("📌 Featured avatars: \(featuredAvatars.map(\.characterOption))")
        } catch {
            dLog("Error loading popular avatars: \(error)")
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
    }
}

#Preview {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService()))
}

#Preview("RealData", body: {
    ExploreView()
        .environment(AvatarManager(service: FirebaseAvatarService()))
})
