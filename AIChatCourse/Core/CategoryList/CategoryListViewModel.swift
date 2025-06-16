//
//  CategoryListViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/16/25.
//

import SwiftUI

@MainActor
protocol CategoryListInteractor {
    func trackEvent(event: LoggableEvent)
    func getAvatarsForCategory(category: CharacterOption) async throws -> [AvatarModel]
}

extension CoreInteractor: CategoryListInteractor {}

@Observable
@MainActor
final class CategoryListViewModel {
    private let interactor: CategoryListInteractor
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = false
    var showAlert: AnyAppAlert?

    init(interactor: CategoryListInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Funcation
    func loadAvatars(category: CharacterOption) async {
        interactor.trackEvent(event: Event.loadAvatarStart)
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            avatars = try await interactor.getAvatarsForCategory(category: category)
            interactor.trackEvent(event: Event.loadAvatarSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            interactor.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        interactor.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
    
    // MARK: -- enum
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess
        case loadAvatarFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart: return "CategoryList_Avatar_Start"
            case .loadAvatarSuccess: return "CategoryList_Avatar_Success"
            case .loadAvatarFail: return "CategoryList_Avatar_Fail"
            case .avatarPressed: return "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
}
