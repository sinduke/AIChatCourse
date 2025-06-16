//
//  ChatRowCellViewBuilder.swift
//  AIChatCourse
//
//  Created by sinduke on 5/18/25.
//

import SwiftUI

@MainActor
protocol ChatRowCellInteractor {
    var auth: UserAuthInfo? { get }
    func getAvatar(id: String) async throws -> AvatarModel
    func getLastChatMessage(chatId: String) async throws -> ChatMessageModel?
}

extension CoreInteractor: ChatRowCellInteractor {}

@Observable
@MainActor
final class ChatRowCellViewModel {
    private let interactor: ChatRowCellInteractor
    
    init(interactor: ChatRowCellInteractor) {
        self.interactor = interactor
    }
    
    private(set) var avatar: AvatarModel?
    private(set) var lastChatMessage: ChatMessageModel?
    private(set) var didLoadAvatar: Bool = false
    private(set) var didLoadChatMessage: Bool = false
    
    var isLoading: Bool {
        !(didLoadAvatar && didLoadChatMessage)
    }
    
    var hasNewChat: Bool {
        guard let lastChatMessage, let currentUserId = interactor.auth?.uid else { return false }
        return !lastChatMessage.hasBeenSeenBy(userId: currentUserId)
    }
    
    func loadAvatar(chat: ChatModel) async {
        avatar = try? await interactor.getAvatar(id: chat.avatarId)
        didLoadAvatar = true
    }
    
    func loadLastMessage(chat: ChatModel) async {
        lastChatMessage = try? await interactor.getLastChatMessage(chatId: chat.id)
        didLoadChatMessage = true
    }
    
}

struct ChatRowCellViewBuilder: View {
    
    @State var viewModel: ChatRowCellViewModel
    var chat: ChatModel = .mock
    
    var body: some View {
        ChatRowCellView(
            imageName: viewModel.avatar?.profileImageName,
            headline: viewModel.isLoading ? "xxx xxx" : viewModel.avatar?.name,
            subheadline: subheadline,
            hasNewChat: viewModel.isLoading ? false : viewModel.hasNewChat
        )
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
        .task {
            await viewModel.loadAvatar(chat: chat)
        }
        .task {
            await viewModel.loadLastMessage(chat: chat)
        }
    }
    
    private var subheadline: String? {
        if viewModel.isLoading {
            return "xxxx xxxx xxxx xxxx"
        }
        if viewModel.avatar == nil && viewModel.lastChatMessage == nil {
            return "Error loading data"
        }
        
        return viewModel.lastChatMessage?.content?.content
    }
}

#Preview {
    
    let container = DevPreview.shared.container
    container.register(
        ChatManager.self,
        service: ChatManager(
            service: MockChatService(
                chats: ChatModel.mocks,
                messages: ChatMessageModel.mocks,
                delay: 5,
                showError: false
            )
        )
    )
    
    return VStack {
        ChatRowCellViewBuilder(
            viewModel: ChatRowCellViewModel(interactor: CoreInteractor(container: container)),
            chat: .mock
        )
    }
}
