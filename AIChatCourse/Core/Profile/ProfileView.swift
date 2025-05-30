//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(UserManager.self) private var userManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var showSettingView: Bool = false
    @State private var currentUser: UserModel?
    @State private var showCreateAvatarView: Bool = false
    @State private var myAvatars: [AvatarModel] = []
    @State private var path: [NavigationPathOption] = []
//    @State private var myAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var isLoading: Bool = true
    @State private var showAlert: AnyAppAlert?
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                
                myInfoSection
                myAvatarsSection

            }
            .navigationTitle("Profile")
            .screenAppearAnalytics(name: "ProfileView")
            .showCustomAlert(alert: $showAlert)
            .navigationDestinationForCoreModult(path: $path)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingButton
                }
            }
        }
        .sheet(isPresented: $showSettingView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView, onDismiss: {
            Task {
                await loadData()
            }
        }, content: {
            CreateAvatarView()
        })
        .task {
            await loadData()
        }
    }
    // MARK: -- View
    private var myAvatarsSection: some View {
        Section {
            if myAvatars.isEmpty {
                Group {
                    if isLoading {
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
                ForEach(myAvatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: nil
                    )
                    .anyButton(.highlight, action: {
                        onAvatarPressed(avatar: avatar)
                    })
                    .removeListRowFormatting()
                }
                .onDelete { indexSet in
                    onDeleteAvatar(indexSet: indexSet)
                }
            }
        } header: {
            HStack {
                Text("My avatars")
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onNewAvatarButtonPressed()
                    }
            }
        }
    }
    
    private var settingButton: some View {
        Image(systemName: "gear")
            .font(.headline)
            .foregroundStyle(.accent)
            .anyButton {
                onSettingButtonPressed()
            }
    }

    private var myInfoSection: some View {
        Section {
            ZStack {
                Circle()
                    .fill(currentUser?.profileColorCalculated ?? .accent)
            }
            .frame(width: 100)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .removeListRowFormatting()
    }
    
    // MARK: -- Funcation
    private func onSettingButtonPressed() {
        showSettingView = true
        logManager.trackEvent(event: Event.settingButtonPressed)
    }
    
    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
        logManager.trackEvent(event: Event.newAvatarButtonPressed)
    }
    
    private func onDeleteAvatar(indexSet: IndexSet) {
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
    
    private func loadData() async {
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
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
    }
    
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
}

#Preview {
    ProfileView()
        .previewEnvrionment()
}
