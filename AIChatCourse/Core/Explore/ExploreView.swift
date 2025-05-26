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
    
    @State private var isLoadingFeatured: Bool = false
    @State private var isLoadingPopular: Bool = false
    
    @State private var path: [NavigationPathOption] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingPopular || isLoadingFeatured {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
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
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8.0) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Try again") {
                onTryAgainPressed()
            }
            .tint(.blue)
        }
        .frame(maxWidth: .infinity )
        .multilineTextAlignment(.center)
        .padding(40)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
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
    private func onTryAgainPressed() {
        Task {
            await loadFeaturedAvatar()
        }
        
        Task {
            await loadPopularAvatar()
        }
    }
    
    private func loadFeaturedAvatar() async {
        isLoadingPopular = true
        isLoadingFeatured = true
        
        defer {
            isLoadingPopular = false
            isLoadingFeatured = false
        }
        
        guard featuredAvatars.isEmpty else { return }
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
        } catch {
            dLog("Error loading feature avatars: \(error)")
        }
    }
    
    private func loadPopularAvatar() async {
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
        } catch {
            dLog("Error loading popular avatars: \(error)")
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
    }
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 0)))
}

#Preview("No Data", body: {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 2.0)))
})

#Preview("Slow Loading", body: {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 10)))
})

#Preview("RealData", body: {
    ExploreView()
        .environment(AvatarManager(service: FirebaseAvatarService()))
})
