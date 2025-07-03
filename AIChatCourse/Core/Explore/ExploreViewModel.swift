//
//  ExploreViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/13/25.
//

import SwiftUI

@MainActor
protocol ExploreInteractor {
    var activeTests: ActiveABTests { get }
    var categoryTest: CategoryRowTestOption { get }
    func trackEvent(event: LoggableEvent)
    func schedulePushNotificationsForNextWeek()
    var createAccountTest: ActiveABTests { get }
    var auth: UserAuthInfo? { get }
    func canRequestAuthorization() async -> Bool
    func getFeaturedAvatars() async throws -> [AvatarModel]
    func getPopularAvatars() async throws -> [AvatarModel]
    func requestAuthorization() async throws -> Bool
}
extension CoreInteractor: ExploreInteractor { }

@Observable
@MainActor
class ExploreViewModel {
    private let interactor: ExploreInteractor
    
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
    
    var activeTest: ActiveABTests {
        interactor.activeTests
    }
    
    var categoryTest: CategoryRowTestOption {
        activeTest.categoryRowTest
    }
    
    init(interactor: ExploreInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Func
    func handleDeepLink(url: URL) {
        interactor.trackEvent(event: Event.deepLinkStart)
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false), let queryItems = components.queryItems else {
            interactor.trackEvent(event: Event.deepLinkNoQueryItems)
            return
        }
        for queryItem in queryItems {
            if queryItem.name == "category", let value = queryItem.value, let category = CharacterOption(rawValue: value.lowercased()) {
                let imageName = popularAvatars.first { $0.characterOption == category }?.profileImageName ?? Constants.randomImage
                path.append(.category(category: category, imageName: imageName))
                interactor.trackEvent(event: Event.deepLinkCategoryPressed(category: category))
                return
            }
        }
        interactor.trackEvent(event: Event.deepLinkUnknown)
    }
    
    func showCreateAccountIfNeed() {
        Task {
            try? await Task.sleep(for: .seconds(2))
            
            guard
                let isAnonymous = interactor.auth?.isAnonymous,
                isAnonymous
// TODO: 这里有问题需要处理
//                interactor.createAccountTest
            else { return }
            
            showCreateAccountView = true
        }
    }
    
    func schedulePushNotifications() {
        interactor.schedulePushNotificationsForNextWeek()
    }

    func handleNotificationsPermission() async {
        showNotificationsModal = await interactor.canRequestAuthorization()
    }

    func checkNotificationsPermission() async {
        showNotificationsButton = await interactor.canRequestAuthorization()
    }
    
    func onDevSettingPressed() {
        interactor.trackEvent(event: Event.devSettingsPressed)
        showDevSetting = true
    }
    
    func onTryAgainPressed() {
        interactor.trackEvent(event: Event.tryAgainPressed)
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
        
        interactor.trackEvent(event: Event.loadFeaturedAvatarStart)
        
        guard featuredAvatars.isEmpty else { return }
        do {
            featuredAvatars = try await interactor.getFeaturedAvatars()
            interactor.trackEvent(event: Event.loadFeaturedAvatarSuccess(count: featuredAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadFeaturedAvatarFail(error: error))
        }
    }
    
    func loadPopularAvatar() async {
        interactor.trackEvent(event: Event.loadPopularAvatarStart)
        guard popularAvatars.isEmpty else { return }
        do {
            popularAvatars = try await interactor.getPopularAvatars()
            interactor.trackEvent(event: Event.loadPopularAvatarSuccess(count: popularAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadPopularAvatarFail(error: error))
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
    func onCategoryPressed(category: CharacterOption, imageName: String) {
        interactor.trackEvent(event: Event.categoryPressed(category: category))
        path.append(.category(category: category, imageName: imageName))
    }
    
    func onEnableNotificationsModalButtonPressed() {
        showNotificationsModal = false
        Task {
            let isAuthorized = try await interactor.requestAuthorization()
            interactor.trackEvent(event: Event.pushNotificationsEnable(isAuthorized: isAuthorized))
            await handleNotificationsPermission()
        }
    }

    func onCancelNotificationsModalButtonPressed() {
        showNotificationsModal = false
        interactor.trackEvent(event: Event.pushNotificationsCancel)
    }
    
    func onNotificationsPressed() {
        showNotificationsModal = true
        interactor.trackEvent(event: Event.pushNotificationsStart)
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
