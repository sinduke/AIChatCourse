//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ProfileView: View {
    
    @Environment(DependencyContainer.self) private var container
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
            .navigationDestinationForCoreModule(path: $viewmodel.path)
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
                    viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: container))
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
    return ProfileView(
//        viewmodel: ProfileViewModel(container: DevPreview.shared.container)
        viewmodel: ProfileViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
    )
    .previewEnvrionment()
}
