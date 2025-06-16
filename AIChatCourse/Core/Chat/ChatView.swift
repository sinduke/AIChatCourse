//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatView: View {
    
    @State var viewModel: ChatViewModel
    
    @Environment(\.dismiss) private var dismiss
    var chat: ChatModel?
    var avatarId: String = AvatarModel.mock.avatarId
    
    // MARK: -- Body
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(viewModel.avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    if viewModel.isGeneratingResponse {
                        ProgressView()
                    }
                    
                    Image(systemName: "ellipsis")
                        .padding(8)
                        .foregroundStyle(.accent)
                        .anyButton {
                            viewModel.onChatSettingPressed(onDeleteChat: {
                                dismiss()
                            })
                        }
                }
            }
        }
        .screenAppearAnalytics(name: "ChatView")
        .showCustomAlert(type: .confirmationDialog, alert: $viewModel.showChatSettings)
        .showCustomAlert(alert: $viewModel.showAlert)
        .showModal(showModal: $viewModel.showProfileModal) {
            if let avatar = viewModel.avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await viewModel.loadAvatar(avatarId: avatarId)
        }
        .task {
            // loadHistoryMessage
            await viewModel.loadChat(avatarId: avatarId)
            await viewModel.listenForChatMessage()
        }
        .onFirstAppear {
            viewModel.onViewFirstAppear(chat: chat)
        }
    }
    
    // MARK: -- View
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(viewModel.chatMessages) { message in
                    
                    if viewModel.messageIsDelayed(message: message) {
                        timestampView(date: message.dateCreatedCalculated)
                    }
                    
                    let isCurrentUser = viewModel.messageIsCurrentUser(message: message)
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        currentUserProfileColor: viewModel.currentUser?.profileColorCalculated ?? .accent,
                        imageName: isCurrentUser ? nil : viewModel.avatar?.profileImageName,
                        onImagePressed: viewModel.onAvatarImagePressed
                    )
                    .onAppear(perform: {
                        viewModel.onMessageDidAppear(message: message)
                    })
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .scrollIndicators(.hidden)

        .rotationEffect(.degrees(180))
        .scrollPosition(id: $viewModel.scrollPosition, anchor: .center)
        .animation(.default, value: viewModel.chatMessages.count)
        .animation(.default, value: viewModel.scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something", text: $viewModel.textFieldText)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        viewModel.onSendMessagePressed(avatarId: avatarId)
                    }
            })
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 100)
                        .fill(.background)
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(.gray.opacity(0.3), lineWidth: 1)
                }
            )
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.background)
            .background(Color(uiColor: .secondarySystemBackground))
    }
    
    // MARK: -- FuncOfView
    private func timestampView(date: Date) -> some View {
        Group {
            Text(date.formatted(date: .abbreviated, time: .omitted))
            +
            Text(" • ")
            +
            Text(date.formatted(date: .omitted, time: .shortened))
        }
        .foregroundStyle(.secondary)
        .font(.callout)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                viewModel.onProfileModalXmarkPressed()
            }
            .padding(40)
            .transition(.slide)
    }
    
}

#Preview("Default") {
    NavigationStack {
        ChatView(viewModel: ChatViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
            .previewEnvrionment()
    }
}

#Preview("AI 延迟回复") {
    let container = DevPreview.shared.container
    container.register(AIManager.self, service: AIManager(service: MockAIService(delay: 10, showError: false)))
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                interactor: CoreInteractor(
                    container: container
                )
            )
        )
        .previewEnvrionment()
    }
}

#Preview("AI 生成失败") {
    /**
     步骤:
     输入合法的(可验证的消息内容 点击发送 1秒后查看结果)
     */
    let container = DevPreview.shared.container
    container.register(
        AIManager.self,
        service: AIManager(
            service: MockAIService(
                delay: 1
            )
        )
    )
    
    return NavigationStack {
        ChatView(
            viewModel: ChatViewModel(
                interactor: CoreInteractor(
                    container: container
                )
            )
        )
        .previewEnvrionment()
    }
}
