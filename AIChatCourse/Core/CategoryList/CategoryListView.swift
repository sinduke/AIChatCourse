//
//  CategoryListView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/20/25.
//

import SwiftUI

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
    
    return CategoryListView(
        viewModel: CategoryListViewModel(
            interactor: CoreInteractor(
                container: container
            )
        ),
        path: .constant([])
    )
        .previewEnvrionment()
}

#Preview("No Data") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(avatars: [])))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvrionment()
}

#Preview("Slow Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 10)))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvrionment()
}

#Preview("Error Loading") {
    let container = DevPreview.shared.container
    container.register(AvatarManager.self, service: AvatarManager(service: MockAvatarService(delay: 1, showError: true)))
    
    return CategoryListView(viewModel: CategoryListViewModel(interactor: CoreInteractor(container: container)), path: .constant([]))
        .previewEnvrionment()
}
