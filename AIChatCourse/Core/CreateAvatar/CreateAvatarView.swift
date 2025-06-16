//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel
    
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributeSection
                imageSection
                saveSection
            }
            .minimumScaleFactor(0.3)
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            })
            .navigationTitle("Create Avatar")
            .screenAppearAnalytics(name: "CreateAvatar")
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
    
    // MARK: -- View
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "save",
                action: {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
                }
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1)
            .disabled(viewModel.generatedImage == nil)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("generate image")
                        .foregroundStyle(.accent)
                        .underline()
                        .anyButton {
                            viewModel.onGeneraImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)
                        .lineLimit(1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay(content: {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    })
                    .clipShape(.circle)
                    .frame(maxWidth: .infinity, maxHeight: 400)
            }
            .removeListRowFormatting()
        }
    }
    
    private var attributeSection: some View {
        Section {
            Picker("is a ...".capitalized, selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("this is ...".capitalized)
            }
            
            Picker(selection: $viewModel.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the ...".capitalized)
            }

        } header: {
            Text("Attributes")
        }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("name your avatar*")
                .lineLimit(1)
                .minimumScaleFactor(0.3)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.press) {
                viewModel.onBackButtonPressed(onDismiss: {
                    dismiss()
                })
            }
    }
    
}

#Preview {
    CreateAvatarView(
        viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: DevPreview.shared.container))
    )
    .previewEnvrionment()
}
