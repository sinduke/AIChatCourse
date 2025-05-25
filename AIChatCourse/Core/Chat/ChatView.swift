//
//  ChatView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct ChatView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(AIManager.self) private var aiManager
    
    @State private var chatMessages: [ChatMessageModel] = ChatMessageModel.mocks
//    @State private var avatar: AvatarModel? = .mock
    @State private var currentUser: UserModel? = .mock
    @State private var avatar: AvatarModel?
    @State private var textFieldText: String = ""
    
    @State private var showChatSettings: AnyAppAlert?
    @State private var scrollPosition: String?
    @State private var showAlert: AnyAppAlert?
    @State private var showProfileModal: Bool = false
    
    var avatarId: String = AvatarModel.mock.avatarId
    
    // MARK: -- Body
    var body: some View {
        VStack(spacing: 0) {
            scrollViewSection
            textFieldSection
        }
        .navigationTitle(avatar?.name ?? "")
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "ellipsis")
                    .padding(8)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onChatSettingPressed()
                    }
            }
        }
        .showCustomAlert(type: .confirmationDialog, alert: $showChatSettings)
        .showCustomAlert(alert: $showAlert)
        .showModal(showModal: $showProfileModal) {
            if let avatar {
                profileModal(avatar: avatar)
            }
        }
        .task {
            await loadAvatar()
        }
    }
    
    // MARK: -- View
    private var scrollViewSection: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                ForEach(chatMessages) { message in
                    let isCurrentUser = message.authorId == currentUser?.userId
                    ChatBubbleViewBuilder(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        imageName: isCurrentUser ? nil : avatar?.profileImageName,
                        onImagePressed: onAvatarImagePressed
                    )
                    .id(message.id)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
            .rotationEffect(.degrees(180))
        }
        .rotationEffect(.degrees(180))
        .scrollPosition(id: $scrollPosition, anchor: .center)
        .animation(.default, value: scrollPosition)
    }
    
    private var textFieldSection: some View {
        TextField("Say something", text: $textFieldText)
            .keyboardType(.alphabet)
            .autocorrectionDisabled()
            .padding(12)
            .padding(.trailing, 60)
            .overlay(alignment: .trailing, content: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .padding(.trailing, 4)
                    .foregroundStyle(.accent)
                    .anyButton {
                        onSendMessagePressed()
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
    private func profileModal(avatar: AvatarModel) -> some View {
        ProfileModalView(
            imageName: avatar.profileImageName,
            title: avatar.name,
            subtitle: avatar.characterOption?.rawValue.capitalized,
            headline: avatar.characterDescription) {
                showProfileModal = false
            }
            .padding(40)
            .transition(.slide)
    }
    
    // MARK: -- Func
    private func loadAvatar() async {
        do {
            let avatar = try await avatarManager.getAvatar(id: avatarId)
            self.avatar = avatar
            // 是否失败无所谓 数据统计类的
            try? await avatarManager.addRecentAvatar(avatar: avatar)
        } catch {
            dLog("Error loading avatar: \(error)")
        }
    }
    
    private func onSendMessagePressed() {
        
        guard let currentUser else { return }
        let content = textFieldText
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: content)
                
                let newMessage = AIChatModel(role: .user, content: content)
                
                let message = ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: currentUser.userId,
                    content: newMessage,
                    seenByIds: nil,
                    dateCreated: .now
                )
                chatMessages.append(message)
                
                scrollPosition = message.id
                
                textFieldText = ""
                
                let aiChats = chatMessages.compactMap({ $0.content })
                
                let response = try await aiManager.generateText(chats: aiChats)
                
                let newAIMessage = ChatMessageModel(
                    id: UUID().uuidString,
                    chatId: UUID().uuidString,
                    authorId: avatarId,
                    content: response,
                    seenByIds: nil,
                    dateCreated: .now
                )
                chatMessages.append(newAIMessage)
            } catch {
                showAlert = AnyAppAlert(error: error)
            }
        }
    }
    
    private func onChatSettingPressed() {
        showChatSettings = AnyAppAlert(
            title: "",
            subtitle: "What would you like to do?",
            buttons: {
                AnyView(
                    Group(content: {
                        Button("Report User / Chat", role: .destructive) {
                            
                        }
                        Button("Delete Chat", role: .destructive) {
                            
                        }
                    })
                )
            }
        )
    }
    
    private func onAvatarImagePressed() {
        showProfileModal = true
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environment(AvatarManager(service: MockAvatarService()))
            .previewEnvrionment()
    }
}
