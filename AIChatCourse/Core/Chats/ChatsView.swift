//
//  ChatsView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ChatsView: View {
    
    @State var viewModel: ChatsViewModel
    @Environment(DependencyContainer.self) private var container
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                if !viewModel.recentAvatars.isEmpty {
                    recentsSection
                }
                chatsSection
            }
            .navigationTitle("Chats")
            .screenAppearAnalytics(name: "Chats")
            .navigationDestinationForCoreModule(path: $viewModel.path)
            .onAppear {
                viewModel.loadRecentAvatars()
            }
            .task {
                await viewModel.loadChats()
            }
        }
    }
    
    // MARK: -- View
    private var recentsSection: some View {
        Section {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.recentAvatars, id: \.self) { avatar in
                        if let imageName = avatar.profileImageName {
                            VStack(spacing: 8) {
                                ImageLoaderView(urlString: imageName)
                                    .aspectRatio(1, contentMode: .fit)
                                    .clipShape(.circle)
                                    .frame(minHeight: 60)
                                
                                Text(avatar.name ?? "")
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                            .anyButton {
                                viewModel.onAvatarPressed(avatar: avatar)
                            }
                        }
                    }
                }
                .padding(.top, 12)
            }
            .frame(height: 120)
            .scrollIndicators(.hidden )
            .removeListRowFormatting()
        } header: {
            Text("Recents")
        }
    }
    
    private var chatsSection: some View {
        Section {
            if viewModel.isLoadingChats {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .removeListRowFormatting()
            } else if viewModel.chats.isEmpty {
                Text("Your chat will appear here!")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(40)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.chats) { chat in
                    ChatRowCellViewBuilder(
                        viewModel: ChatRowCellViewModel(interactor: CoreInteractor(container: container)),
                        chat: chat
                    )
                    .anyButton(.highlight, action: {
                        viewModel.onChatPressed(chat: chat)
                    })
                    .removeListRowFormatting()
                }
            }
        } header: {
            Text(viewModel.chats.isEmpty ? "" : "Chats")
        }
    }
}

#Preview("Default") {
    ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvrionment()
}

#Preview("No Data") {
    
    let container = DevPreview.shared.container
    container.register(
        AvatarManager.self,
        service: AvatarManager(
            service: MockAvatarService(avatars: []),
            local: MockLocalAvatarPersistence(avatars: [])
        )
    )
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvrionment()
}

#Preview("慢加载") {
    
    let container = DevPreview.shared.container
    container.register(ChatManager.self, service: ChatManager(service: MockChatService(delay: 5)))
    
    return ChatsView(viewModel: ChatsViewModel(interactor: CoreInteractor(container: container)))
        .previewEnvrionment()
}

#Preview("开关状态测试") {
    @Previewable @State var isOn = true      // 👈 直接声明动态属性
    Toggle("启用高级动画", isOn: $isOn)
        .padding()
}
