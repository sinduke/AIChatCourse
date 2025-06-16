//
//  CreateAvatarViewModel.swift
//  AIChatCourse
//
//  Created by sinduke on 6/16/25.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
    func getAuthId() throws -> String
    func createAvatar(avatar: AvatarModel, image: UIImage) async throws
}

extension CoreInteractor: CreateAvatarInteractor {}

@Observable
@MainActor
final class CreateAvatarViewModel {
    private let interactor: CreateAvatarInteractor
    private(set) var isGenerating: Bool = false
    private(set) var isSaving: Bool = false
    
    init(interactor: CreateAvatarInteractor) {
        self.interactor = interactor
    }
    
    // MARK: -- Binding
    var generatedImage: UIImage?
    var showAlert: AnyAppAlert?
    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    
    // MARK: -- Function
    func onBackButtonPressed(onDismiss: () -> Void) {
        interactor.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onGeneraImagePressed() {
        interactor.trackEvent(event: Event.generateImageStart)
        isGenerating = true
        
        Task {
            defer {
                isGenerating = false
            }
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                
                let prompt = avatarDescriptionBuilder.charcaterDescription
                
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
        }
    }
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSaving = true
        Task {
            defer {
                isSaving = false
            }
            
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterContent: 4)
                let uid = try interactor.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    local: characterLocation,
                    authorId: uid
                )
                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                onDismiss()
            } catch {
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    // MARK: -- Enum
    enum Event: LoggableEvent {
        case backButtonPressed
        
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)
        
        var eventName: String {
            switch self {
            case .backButtonPressed: return "CreateAvatarView_BackButton_Pressed"
            
            case .generateImageStart: return "CreateAvatarView_GenImage_Start"
            case .generateImageSuccess: return "CreateAvatarView_GenImage_Success"
            case .generateImageFail: return "CreateAvatarView_GenImage_Fail"
            
            case .saveAvatarStart: return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess: return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail: return "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
        
    }
    
}
