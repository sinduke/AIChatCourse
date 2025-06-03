//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager
    
    @State private var featuredAvatars: [AvatarModel] = []
    @State private var categories: [CharacterOption] = CharacterOption.allCases
    @State private var popularAvatars: [AvatarModel] = []
    
    @State private var isLoadingFeatured: Bool = false
    @State private var isLoadingPopular: Bool = false
    
    @State private var path: [NavigationPathOption] = []
    @State private var showDevSetting: Bool = false
    @State private var showNotificationsButton: Bool = false
    @State private var showNotificationsModal: Bool = false
    
    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    // MARK: -- View
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
            .screenAppearAnalytics(name: "ExploreView")
            .sheet(isPresented: $showDevSetting, content: {
                DevSettingsView()
            })
            .showModal(showModal: $showNotificationsModal, content: {
                  notificationsModal
            })
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if showNotificationsButton {
                        notificationsButton
                    }
                }
            }
            .navigationDestinationForCoreModult(path: $path)
            .task {
                await loadFeaturedAvatar()
            }
            .task {
                await loadPopularAvatar()
            }
            .task {
                await checkNotificationsPermission()
            }
            .onFirstAppear {
                schedulePushNotifications()
            }
        }
    }

    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForNextWeek()
    }

    private func handleNotificationsPermission() async {
        showNotificationsModal = await pushManager.canRequestAuthorization()
    }

    private func checkNotificationsPermission() async {
        showNotificationsButton = await pushManager.canRequestAuthorization()
    }

    private var notificationsModal: some View {
        CustomModalView(
            title: "Notifications",
            subtitle: "Enable notifications to get the latest updates and news.",
            primaryButtonTitle: "Enable",
            secondaryButtonTitle: "Cancel",
            primaryButtonAction: onEnableNotificationsModalButtonPressed,
            secondaryButtonAction: onCancelNotificationsModalButtonPressed
        )
    }

    private func onEnableNotificationsModalButtonPressed() {
        showNotificationsModal = false
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotificationsEnable(isAuthorized: isAuthorized))
            await handleNotificationsPermission()
        }
    }

    private func onCancelNotificationsModalButtonPressed() {
        showNotificationsModal = false
        logManager.trackEvent(event: Event.pushNotificationsCancel)
    }

    private var notificationsButton: some View {
        Image(systemName: "bell")
            .font(.headline)
            .padding(4)
            .foregroundStyle(.accent)
            .anyButton(.plain) {
                onNotificationsPressed()
            }
    }

    private func onNotificationsPressed() {
        showNotificationsModal = true
        logManager.trackEvent(event: Event.pushNotificationsStart)
    }
    
    private var devSettingButton: some View {
        Text("DEV 🧑‍💻")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingPressed()
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
    private func onDevSettingPressed() {
        logManager.trackEvent(event: Event.devSettingsPressed)
        showDevSetting = true
    }
    
    private func onTryAgainPressed() {
        logManager.trackEvent(event: Event.tryAgainPressed)
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
        
        logManager.trackEvent(event: Event.loadFeaturedAvatarStart)
        
        guard featuredAvatars.isEmpty else { return }
        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarSuccess(count: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarFail(error: error))
        }
    }
    
    private func loadPopularAvatar() async {
        logManager.trackEvent(event: Event.loadPopularAvatarStart)
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarFail(error: error))
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryPressed(category: category))
        path.append(.category(category: category, imageName: imageName))
    }
    
    // MARK: -- Enum
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarStart
        case loadFeaturedAvatarSuccess(count: Int)
        case loadFeaturedAvatarFail(error: Error)
        case loadPopularAvatarStart
        case loadPopularAvatarSuccess(count: Int)
        case loadPopularAvatarFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotificationsStart
        case pushNotificationsEnable(isAuthorized: Bool)
        case pushNotificationsCancel
        
        var eventName: String {
            switch self {
            case .devSettingsPressed: return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed: return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarStart: return "ExploreView_LoadFeaturedAvatar_Start"
            case .loadFeaturedAvatarSuccess: return "ExploreView_LoadFeaturedAvatar_Success"
            case .loadFeaturedAvatarFail: return "ExploreView_LoadFeaturedAvatar_Fail"
            case .loadPopularAvatarStart: return "ExploreView_LoadPopularAvatar_Start"
            case .loadPopularAvatarSuccess: return "ExploreView_LoadPopularAvatar_Success"
            case .loadPopularAvatarFail: return "ExploreView_LoadPopularAvatar_Fail"
            case .avatarPressed: return "ExploreView_Avatar_Pressed"
            case .categoryPressed: return "ExploreView_Category_Pressed"
            case .pushNotificationsStart: return "ExploreView_PushNotifications_Start"
            case .pushNotificationsEnable: return "ExploreView_PushNotifications_Enable"
            case .pushNotificationsCancel: return "ExploreView_PushNotifications_Cancel"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadFeaturedAvatarSuccess(let count), .loadPopularAvatarSuccess(let count):
                return ["avatar_count": count]
            case .loadFeaturedAvatarFail(let error), .loadPopularAvatarFail(let error):
                return error.eventParameters
            case .avatarPressed(let avatar):
                return avatar.eventParameters
            case .categoryPressed(let category):
                return ["category": category.rawValue]
            case .pushNotificationsEnable(let isAuthorized):
                return ["is_authorized": isAuthorized]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeaturedAvatarFail, .loadPopularAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
}

#Preview("Has Data") {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(delay: 0)))
        .previewEnvrionment()
}

#Preview("No Data", body: {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 2.0)))
        .previewEnvrionment()
})

#Preview("Slow Loading", body: {
    ExploreView()
        .environment(AvatarManager(service: MockAvatarService(avatars: [], delay: 10)))
        .previewEnvrionment()
})

#Preview("RealData", body: {
    ExploreView()
        .environment(AvatarManager(service: FirebaseAvatarService()))
        .previewEnvrionment()
})
