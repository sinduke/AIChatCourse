//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

@Observable
@MainActor
class ExploreViewModel {
    private let authManager: AuthManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    private let pushManager: PushManager
    private let abTestManager: ABTestManager
    
    private(set) var featuredAvatars: [AvatarModel] = []
    private(set) var categories: [CharacterOption] = CharacterOption.allCases
    private(set) var popularAvatars: [AvatarModel] = []
    private(set) var isLoadingFeatured: Bool = false
    private(set) var isLoadingPopular: Bool = false
    private(set) var showNotificationsButton: Bool = false
    
    var showNotificationsModal: Bool = false
    var showCreateAccountView: Bool = false
    var path: [NavigationPathOption] = []
    var showDevSetting: Bool = false
    
    var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
        self.pushManager = container.resolve(PushManager.self)!
        self.abTestManager = container.resolve(ABTestManager.self)!
    }
    
    // MARK: -- Func
    func handleDeepLink(url: URL) {
        logManager.trackEvent(event: Event.deepLinkStart)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            logManager.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value.lowercased()) {
                let imageName = popularAvatars.first { $0.characterOption == category }?.profileImageName ?? Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                logManager.trackEvent(event: Event.deepLinkCategoryPressed(category: category))
                return
            }
        }
        logManager.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func showCreateAccountIfNeed() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            guard
                let isAnonymous = authManager.auth?.isAnonymous,
                isAnonymous,
                abTestManager.activeTests.createAccountTest
            else { return }
            
            showCreateAccountView = true
        }
    }
    
    func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForNextWeek()
    }

    func handleNotificationsPermission() async {
        showNotificationsModal = await pushManager.canRequestAuthorization()
    }

    func checkNotificationsPermission() async {
        showNotificationsButton = await pushManager.canRequestAuthorization()
    }
    
    func onDevSettingPressed() {
        logManager.trackEvent(event: Event.devSettingsPressed)
        showDevSetting = true
    }
    
    func onTryAgainPressed() {
        logManager.trackEvent(event: Event.tryAgainPressed)
        Task {
            await loadFeaturedAvatar()
        }
        
        Task {
            await loadPopularAvatar()
        }
    }
    
    func loadFeaturedAvatar() async {
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
    
    func loadPopularAvatar() async {
        logManager.trackEvent(event: Event.loadPopularAvatarStart)
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarFail(error: error))
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        logManager.trackEvent(event: Event.categoryPressed(category: category))
        path.append(.category(category: category, imageName: imageName))
    }
    
    func onEnableNotificationsModalButtonPressed() {
        showNotificationsModal = false
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotificationsEnable(isAuthorized: isAuthorized))
            await handleNotificationsPermission()
        }
    }

    func onCancelNotificationsModalButtonPressed() {
        showNotificationsModal = false
        logManager.trackEvent(event: Event.pushNotificationsCancel)
    }
    
    func onNotificationsPressed() {
        showNotificationsModal = true
        logManager.trackEvent(event: Event.pushNotificationsStart)
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
        case deepLinkStart
        case deepLinkNoQueryItems
        case deepLinkCategoryPressed(category: CharacterOption)
        case deepLinkUnknown
        
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
            case .deepLinkStart: return "ExploreView_DeepLink_Start"
            case .deepLinkNoQueryItems: return "ExploreView_DeepLink_NoQueryItems"
            case .deepLinkCategoryPressed: return "ExploreView_DeepLink_CategoryPressed"
            case .deepLinkUnknown: return "ExploreView_DeepLink_Unknown"
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
            case .categoryPressed(let category), .deepLinkCategoryPressed(let category):
                return ["category": category.rawValue]
            case .pushNotificationsEnable(let isAuthorized):
                return ["is_authorized": isAuthorized]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadFeaturedAvatarFail, .loadPopularAvatarFail, .deepLinkUnknown:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
}

struct ExploreView: View {
    
    @State var viewModel: ExploreViewModel
    
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
                DevSettingsView()
            })
            .showModal(showModal: $viewModel.showNotificationsModal, content: {
                  notificationsModal
            })
            .sheet(isPresented: $viewModel.showCreateAccountView, content: {
                CreateAccountView()
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
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvrionment()
}

#Preview("Has Data CreateAccount Test") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 0)))
    container.register(AuthManager.self, service: AuthManager(service: MockAuthService(user: .mock(isAnonymous: true))))
    container.register(ABTestManager.self, service: ABTestManager(service: MockABTestsService(createAccountTest: true)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvrionment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [], delay: 2.0)))
     
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvrionment()
}

#Preview("Slow Loading", body: {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [], delay: 10)))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvrionment()
})

#Preview("RealData", body: {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: FirebaseAvatarService()))
    
    return ExploreView(viewModel: ExploreViewModel(container: container))
        .previewEnvrionment()
})
