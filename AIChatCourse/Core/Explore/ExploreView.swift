//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

@MainActor
struct CoreBuilder {
    func createAccountView(container: DependencyContainer) -> some View {
        CreateAccountView(viewModel: CreateAccountViewModel(interactor: CoreInteractor(container: container)))
    }
    
    func createDevSettingView() -> some View {
        DevSettingsView()
    }
}

struct ExploreView: View {
    
    @State var viewModel: ExploreViewModel
    @Environment(DependencyContainer.self) private var container
    
    // MARK: -- View
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if viewModel.featuredAvatars.isEmpty && viewModel.popularAvatars.isEmpty {
                    ZStack {
                        if viewModel.isLoadingPopular || viewModel.isLoadingFeatured {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !viewModel.featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !viewModel.popularAvatars.isEmpty {
                    categoriesSection
                    popularSection
                }
                
            }
            .minimumScaleFactor(0.3)
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .sheet(isPresented: $viewModel.showDevSetting, content: {
                CoreBuilder().createDevSettingView()
            })
            .showModal(showModal: $viewModel.showNotificationsModal, content: {
                  notificationsModal
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                CoreBuilder().createAccountView(container: container)
                    .presentationDetents([.medium])
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.showDevSettingsButton {
                        devSettingButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.showNotificationsButton {
                        notificationsButton
                    }
                }
            }
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .task {
                await viewModel.loadFeaturedAvatar()
            }
            .task {
                await viewModel.loadPopularAvatar()
            }
            .task {
                await viewModel.checkNotificationsPermission()
            }
            .onFirstAppear {
                viewModel.schedulePushNotifications()
                viewModel.showCreateAccountIfNeed()
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }

    private var notificationsModal: some View {
        CustomModalView(
            title: "Notifications",
            subtitle: "Enable notifications to get the latest updates and news.",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Cancel",
            primaryButtonAction: viewModel.onEnableNotificationsModalButtonPressed,
            secondaryButtonAction: viewModel.onCancelNotificationsModalButtonPressed
        )
    }

    private var notificationsButton: some View {
        Image(systemName: "bell")
            .font(.headline)
            .padding(4)
            .foregroundStyle(.accent)
            .anyButton(.plain) {
                viewModel.onNotificationsPressed()
            }
    }

    private var devSettingButton: some View {
        Text("DEV 🧑‍💻")
            .badgeButton()
            .anyButton(.press) {
                viewModel.onDevSettingPressed()
            }
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8.0) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Try again") {
                viewModel.onTryAgainPressed()
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
                CarouselView(items: viewModel.featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subTitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        viewModel.onAvatarPressed(avatar: avatar)
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
                    ForEach(viewModel.categories, id: \.self) { category in
                        
                        if let imageName = viewModel.popularAvatars.last(where: { $0.characterOption == category })?.profileImageName {
                            CategoryCellView(
                                title: category.rawValue.capitalized,
                                imageName: imageName
                            )
                            .scrollTargetLayout()
                            .anyButton(.highlight) {
                                viewModel.onCategoryPressed(category: category, imageName: imageName)
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
            ForEach(viewModel.popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subTitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    viewModel.onAvatarPressed(avatar: avatar)
                }
            }
        } header: {
            Text("Popular")
        }
        .removeListRowFormatting()
    }
    
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 0)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
}

#Preview("Has Data CreateAccount Test") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 0)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestsService(createAccountTest: true)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [], delay: 2.0)))
     
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
}

#Preview("Slow Loading", body: {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [], delay: 10)))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
})

#Preview("RealData", body: {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: FirebaseAvatarService()))
    
    return ExploreView(viewModel: ExploreViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
})
