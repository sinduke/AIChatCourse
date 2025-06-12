//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarViewModel {
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    private(set) var isGenerating: Bool = false
    private(set) var isSaving: Bool = false
    
    // MARK: -- Binding
    var generatedImage: UIImage?
    var showAlert: AnyAppAlert?
    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    // MARK: -- Function
    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onGeneraImagePressed() {
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
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
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
                onDismiss()
            } catch {
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
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

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel
    
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
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
    
    // MARK: -- View
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "save",
                action: {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
                }
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1)
            .disabled(viewModel.generatedImage == nil)
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
                            viewModel.onGeneraImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)
                        .lineLimit(1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay(content: {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
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
            Picker("is a ...".capitalized, selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("this is ...".capitalized)
            }
            
            Picker(selection: $viewModel.characterLocation) {
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
            TextField("Player 1", text: $viewModel.avatarName)
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
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
    }
    
}

#Preview {
    CreateAvatarView(
        viewModel: CreateAvatarViewModel(container: DevPreview.shared.container)
    )
    .previewEnvrionment()
}
