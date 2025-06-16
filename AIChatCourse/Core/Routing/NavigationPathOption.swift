//
//  NavigationPathOption.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

enum NavigationPathOption: Hashable {
    case chat(avatarId: String, chat: ChatModel?)
    case category(category: CharacterOption, imageName: String)
}

struct NavDestinationForCoreModuleViewModifier: ViewModifier {
    @Environment(DependencyContainer.self) private var container
    let path: Binding<[NavigationPathOption]>
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: NavigationPathOption.self) { newValue in
                switch newValue {
                case .chat(avatarId: let avatarId, chat: let chat):
                    ChatView(chat: chat, avatarId: avatarId)
                case .category(category: let category, imageName: let imageName):
                    CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: path, category: category, imageName: imageName)
                }
            }
    }
}

extension View {
    func navigationDestinationForCoreModule(path: Binding<[NavigationPathOption]>) -> some View {
        modifier(NavDestinationForCoreModuleViewModifier(path: path))
    }
}
