//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

@Observable
@MainActor
class ProfileViewModel {
    let userManager: UserManager
    let authManager: AuthManager
    let avatarManager: AvatarManager
    let logManager: LogManager
    let aiManager: AIManager
    
    private(set) var currentUser: UserModel?
    private(set) var myAvatars: [AvatarModel] = []
    private(set) var isLoading: Bool = true
    
    var showCreateAvatarView: Bool = false
    var showSettingView: Bool = false
    var showAlert: AnyAppAlert?
    var path: [NavigationPathOption] = []
    
    init(userManager: UserManager, authManager: AuthManager, avatarManager: AvatarManager, logManager: LogManager, aiManager: AIManager) {
        self.userManager = userManager
        self.authManager = authManager
        self.avatarManager = avatarManager
        self.logManager = logManager
        self.aiManager = aiManager
    }
    
    func loadData() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        self.currentUser = userManager.currentUser
           
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuth(userId: uid)
            logManager.trackEvent(event: Event.loadAvatarSuccess(count: myAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
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
        logManager.trackEvent(event: Event.settingButtonPressed)
    }
    
    func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.newAvatarButtonPressed)
    }
    
    func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        let avatar = myAvatars[index]
        logManager.trackEvent(event: Event.deleteAvatarStart(avatar: avatar))
        Task {
            do {
                try await avatarManager.removeAuthorIdFromAllAvatars(userId: avatar.id)
                myAvatars.remove(at: index)
                logManager.trackEvent(event: Event.deleteAvatarSuccess(avatar: avatar))
            } catch {
                showAlert = AnyAppAlert(title: "Unable to delete avatar.", subtitle: "Please try again")
                logManager.trackEvent(event: Event.deleteAvatarFail(error: error))
            }
        }
        
    }
    
    func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
}

struct ProfileView: View {
    
    @State var viewmodel: ProfileViewModel
    
    var body: some View {
        NavigationStack(path: $viewmodel.path) {
            List {
                
                myInfoSection
                myAvatarsSection

            }
            .navigationTitle("Profile")
            .screenAppearAnalytics(name: "ProfileView")
            .showCustomAlert(alert: $viewmodel.showAlert)
            .navigationDestinationForCoreModult(path: $viewmodel.path)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingButton
                }
            }
        }
        .sheet(isPresented: $viewmodel.showSettingView) {
            SettingsView()
        }
        .fullScreenCover(
            isPresented: $viewmodel.showCreateAvatarView,
            onDismiss: {
                Task {
                    await viewmodel.loadData()
                }
            },
            content: {
                CreateAvatarView(
                    viewModel: CreateAvatarViewModel(
                        authManager: viewmodel.authManager,
                        aiManager: viewmodel.aiManager,
                        avatarManager: viewmodel.avatarManager,
                        logManager: viewmodel.logManager
                    )
                )
        })
        .task {
            await viewmodel.loadData()
        }
    }
    // MARK: -- View
    private var myAvatarsSection: some View {
        Section {
            if viewmodel.myAvatars.isEmpty {
                Group {
                    if viewmodel.isLoading {
                        ProgressView()
                    } else {
                        Text("Click to create an avatar")
                    }
                }
                .padding(50)
                .frame(maxWidth: .infinity)
                .font(.body)
                .foregroundStyle(.secondary)
                .removeListRowFormatting()
            } else {
                ForEach(viewmodel.myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: nil
                    )
                    .anyButton(.highlight, action: {
                        viewmodel.onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    viewmodel.onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack {
                Text("My avatars")
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        viewmodel.onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    private var settingButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                viewmodel.onSettingButtonPressed()
            }
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(viewmodel.currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .removeListRowFormatting()
    }
}

#Preview {
    ProfileView(
        viewmodel: ProfileViewModel(
            userManager: DevPreview.shared.userManager,
            authManager: DevPreview.shared.authManager,
            avatarManager: DevPreview.shared.avatarManager,
            logManager: DevPreview.shared.logManager, aiManager: DevPreview.shared.aiManager 
        )
    )
    .previewEnvrionment()
}
