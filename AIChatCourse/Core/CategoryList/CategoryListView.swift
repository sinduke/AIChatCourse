//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

@Observable
@MainActor
class CategoryListViewModel {
    private let avatarManager: AvatarManager
    private let logManager: LogManager
    
    private(set) var avatars: [AvatarModel] = []
    private(set) var isLoading: Bool = false
    
    var showAlert: AnyAppAlert?
    
    init(container: DependencyContainer) {
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
 
    // MARK: -- Funcation
    func loadAvatars(category: CharacterOption) async {
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
    
    func onAvatarPressed(avatar: AvatarModel, path: Binding<[NavigationPathOption]>) {
        path.wrappedValue.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
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
    
}

struct CategoryListView: View {
    
    @State var viewModel: CategoryListViewModel
    
    @Binding var path: [NavigationPathOption]
    var category: CharacterOption = .alien
    var imageName: String = Constants.randomImage
    
    var body: some View {
        List {
            CategoryCellView(
                title: category.plural.capitalized,
                imageName: imageName,
                font: .largeTitle,
                cornerRadius: 0
            )
            .removeListRowFormatting()
            
            if viewModel.isLoading {
                ProgressView()
                    .padding(40)
                    .frame(maxWidth: .infinity)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else if viewModel.avatars.isEmpty {
                Text("No avatars found")
                    .frame(maxWidth: .infinity)
                    .padding(40)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
                    .removeListRowFormatting()
            } else {
                ForEach(viewModel.avatars, id: \.self) { avatar in
                    CustomListCellView(
                        imageName: avatar.profileImageName,
                        title: avatar.name,
                        subTitle: avatar.characterDescription
                    )
                    .anyButton(.highlight) {
                        viewModel.onAvatarPressed(avatar: avatar, path: $path)
                    }
                }
                .removeListRowFormatting()
            }
            
        }
        .screenAppearAnalytics(name: "CategoryList")
        .showCustomAlert(alert: $viewModel.showAlert)
        .ignoresSafeArea(.container, edges: [.top, .horizontal])
        .listStyle(.plain)
        .task {
            await viewModel.loadAvatars(category: category)
        }
    }
    
}

#Preview("Has Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService()))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvrionment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [])))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvrionment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 10)))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvrionment()
}

#Preview("Error Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 1, showError: true)))
    
    return CategoryListView(viewModel: CategoryListViewModel(container: container), path: .constant([]))
        .previewEnvrionment()
}
