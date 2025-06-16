//
//  ProfileViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/13/25.
//

import SwiftUI

@MainActor
protocol ProfileInteractor {
    var currentUser: UserModel? { get }
    func getAuthId() throws -> String
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel]
    func trackEvent(event: LoggableEvent)
    func removeAuthorIdFromAllAvatars(userId: String) async throws
}

extension CoreInteractor: ProfileInteractor {}

@MainActor
struct ProdProfileInteractor: ProfileInteractor {
    // MARK: -- Config
    let userManager: UserManager
    let authManager: AuthManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    // MARK: -- Init
    init(container: DependencyContainer) {
        self.userManager = container.resolve(UserManager.self)!
        self.authManager = container.resolve(AuthManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    var currentUser: UserModel? {
        userManager.currentUser
    }
    
    // MARK: -- Funcation
    func getAuthId() throws -> String {
        try authManager.getAuthId()
    }
    
    func getAvatarsForAuth(userId: String) async throws -> [AvatarModel] {
        try await avatarManager.getAvatarsForAuth(userId: userId)
    }
    
    func trackEvent(event: LoggableEvent) {
        logManager.trackEvent(event: event)
    }
    
    func removeAuthorIdFromAllAvatars(userId: String) async throws {
        try await avatarManager.removeAuthorIdFromAllAvatars(userId: userId)
    }
}

@Observable
@MainActor
class ProfileViewModel {
    
    private let interactor: ProfileInteractor
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showCreateAvatarView: Bool = false
    var showSettingView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(interactor: ProfileInteractor) {
        self.interactor = interactor
    }
    
    func loadData() async {
        interactor.trackEvent(event: Event.loadAvatarStart)
        self.currentUser = interactor.currentUser
           
        do {
            let uid = try interactor.getAuthId()
            myAvatars = try await interactor.getAvatarsForAuth(userId: uid)
            interactor.trackEvent(event: Event.loadAvatarSuccess(count: myAvatars.count))
        } catch {
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
        
        isLoading = false
    }
    
    // MARK: -- Event
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess(count: Int)
        case loadAvatarFail(error: Error)
        
        case deleteAvatarStart(avatar: AvatarModel)
        case deleteAvatarSuccess(avatar: AvatarModel)
        case deleteAvatarFail(error: Error)

        case settingButtonPressed
        case newAvatarButtonPressed
        case avatarPressed(avatar: AvatarModel)

        var eventName: String {
            switch self {
            case .loadAvatarStart: return "ProfileView_LoadAvatar_Start"
            case .loadAvatarSuccess: return "ProfileView_LoadAvatar_Success"
            case .loadAvatarFail: return "ProfileView_LoadAvatar_Fail"

            case .deleteAvatarStart: return "ProfileView_DeleteAvatar_Start"
            case .deleteAvatarSuccess: return "ProfileView_DeleteAvatar_Success"
            case .deleteAvatarFail: return "ProfileView_DeleteAvatar_Fail"

            case .settingButtonPressed: return "ProfileView_SettingButton_Pressed"
            case .newAvatarButtonPressed: return "ProfileView_NewAvatarButton_Pressed"
            case .avatarPressed: return "ProfileView_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarSuccess(let count): return ["avatar_count": count]
            case .loadAvatarFail(let error), .deleteAvatarFail(let error): return error.eventParameters

            case .deleteAvatarSuccess(let avatar), .deleteAvatarStart(avatar: let avatar), .avatarPressed(let avatar):
                return avatar.eventParameters

            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail, .deleteAvatarFail: return .severe
            default:
                return .analytic
            }
        }
        
    }
    
    // MARK: -- Funcation
    func onSettingButtonPressed() {
        showSettingView = true
        interactor.trackEvent(event: Event.settingButtonPressed)
    }
    
    func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
        interactor.trackEvent(event: Event.newAvatarButtonPressed)
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        interactor.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        Task {
            do {
                try await interactor.removeAuthorIdFromAllAvatars(userId: avatar.id)
                myAvatars.remove(at: index)
                interactor.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar.", subtitle: "Please try again")
                interactor.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
        
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
}
