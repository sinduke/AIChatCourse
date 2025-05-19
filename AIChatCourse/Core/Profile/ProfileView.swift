//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ProfileView: View {
    
    @State private var showSettingView: Bool = false
    @State private var currentUser: UserModel? = .mock
    @State private var showCreateAvatarView: Bool = false
    @State private var myAvatars: [AvatarModel] = []
//    @State private var myAvatars: [AvatarModel] = AvatarModel.mocks
    @State private var isLoading: Bool = true
    
    var body: some View {
        NavigationStack {
            List {
                myInfoSection
                myAvatarsSection

            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    settingButton
                }
            }
        }
        .sheet(isPresented: $showSettingView) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $showCreateAvatarView) {
            CreateAvatarView()
        }
        .task {
            await loadData()
        }
    }

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
        try? await Task.sleep(for: .seconds(5))
        isLoading = false
        myAvatars = AvatarModel.mocks
//        myAvatars = []
    }
}

#Preview {
    ProfileView()
        .environment(AppState())
}
