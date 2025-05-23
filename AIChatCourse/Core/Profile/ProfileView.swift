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
    
    @State private var showSettingView: Bool = false
    @State private var currentUser: UserModel?
    @State private var showCreateAvatarView: Bool = false
    @State private var myAvatars: [AvatarModel] = []
    @State private var path: [NavigationPathOption] = []
//    @State private var myAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack(path: $path) {
            List {
                
                myInfoSection
                myAvatarsSection

            }
            .navigationTitle("Profile")
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
    }
    
    private func onNewAvatarButtonPressed() {
        showCreateAvatarView = true
    }
    
    private func onDeleteAvatar(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        myAvatars.remove(at: index)
    }
    
    private func loadData() async {
        self.currentUser = userManager.currentUser
           
        do {
            let uid = try authManager.getAuthId()
            myAvatars = try await avatarManager.getAvatarsForAuth(userId: uid)
        } catch {
            dLog("Faild to fetch user's avatars")
        }
        
        isLoading = false
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId))
    }
}

#Preview {
    ProfileView()
        .environment(UserManager(services: MockUserServices(user: .mock)))
        .environment(AppState())
        .environment(AvatarManager(service: MockAvatarService()))
}
