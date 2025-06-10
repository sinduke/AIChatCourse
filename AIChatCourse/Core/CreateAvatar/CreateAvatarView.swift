//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var isSaving: Bool = false
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributeSection
                imageSection
                saveSection
            }
            .minimumScaleFactor(0.3)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            })
            .navigationTitle("Create Avatar")
            .screenAppearAnalytics(name: "CreateAvatar")
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    // MARK: -- View
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                title: "save",
                action: onSavePressed
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(generatedImage == nil ? 0.5 : 1)
            .disabled(generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("generate image")
                        .foregroundStyle(.accent)
                        .underline()
                        .anyButton {
                            onGeneraImagePressed()
                        }
                        .opacity(isGenerating ? 0 : 1)
                        .lineLimit(1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay(content: {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    })
                    .clipShape(.circle)
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
            .removeListRowFormatting()
        }
    }
    
    private var attributeSection: some View {
        Section {
            Picker("is a ...".capitalized, selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("this is ...".capitalized)
            }
            
            Picker(selection: $characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the ...".capitalized)
            }

        } header: {
            Text("Attributes")
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.press) {
                onBackButtonPressed()
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
    
    // MARK: -- Function
    private func onBackButtonPressed() {
        logManager.trackEvent(event: Event.backButtonPressed)
        dismiss()
    }
    
    private func onGeneraImagePressed() {
        logManager.trackEvent(event: Event.generateImageStart)
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
                
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
        }
    }
    
    private func onSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }
        isSaving = true
        Task {
            defer {
                isSaving = false
            }
            
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterContent: 4)
                let uid = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    local: characterLocation,
                    authorId: uid
                )
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                dismiss()
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AuthManager(service: MockAuthService(user: .mock())))
        .previewEnvrionment()
}
