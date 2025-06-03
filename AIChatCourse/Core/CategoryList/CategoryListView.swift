//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

struct CategoryListView: View {
    @Environment(LogManager.self) private var logManager
    @Environment(AvatarManager.self) private var avatarManager
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    @State private var avatars: [AvatarModel] = []
    @State private var showAlert: AnyAppAlert?
    @State private var isLoading: Bool = false
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if avatars.isEmpty {
                Text("No avatars found")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        onAvatarPressed(avatar: avatar)
                    }
                }
                .removeListRowFormatting()
            }
            
        }
        .screenAppearAnalytics(name: "CategoryList")
        .showCustomAlert(alert: $showAlert)
        .ignoresSafeArea()
        .listStyle(.plain)
        .task {
            await loadAvatars()
        }
    }
    
    // MARK: -- enum
    enum Event: LoggableEvent {
        case loadAvatarStart
        case loadAvatarSuccess
        case loadAvatarFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        
        var eventName: String {
            switch self {
            case .loadAvatarStart: return "CategoryList_Avatar_Start"
            case .loadAvatarSuccess: return "CategoryList_Avatar_Success"
            case .loadAvatarFail: return "CategoryList_Avatar_Fail"
            case .avatarPressed: return "CategoryList_Avatar_Pressed"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadAvatarFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadAvatarFail:
                return .severe
            default:
                return .analytic
            }
        }
        
    }
    
    // MARK: -- Funcation
    private func loadAvatars() async {
        logManager.trackEvent(event: Event.loadAvatarStart)
        isLoading = true
        defer {
            isLoading = false
        }
        do {
            avatars = try await avatarManager.getAvatarsForCategory(category: category)
            logManager.trackEvent(event: Event.loadAvatarSuccess)
        } catch {
            showAlert = AnyAppAlert(error: error)
            logManager.trackEvent(event: Event.loadAvatarFail(error: error))
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }
}

#Preview("Has Data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService()))
        .previewEnvrionment()
}

#Preview("No Data") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(avatars: [])))
        .previewEnvrionment()
}

#Preview("Slow Loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 10)))
        .previewEnvrionment()
}

#Preview("Error Loading") {
    CategoryListView(path: .constant([]))
        .environment(AvatarManager(service: MockAvatarService(delay: 1, showError: true)))
        .previewEnvrionment()
}
