//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/19/25.
//

import SwiftUI

struct CreateAvatarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    @State private var isGenerating: Bool = false
    @State private var generatedImage: UIImage?
    @State private var isSaving: Bool = false
    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributeSection
                imageSection
                saveSection
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            })
            .navigationTitle("Create Avatar")
        }
    }
    
    // MARK: -- View
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: isSaving,
                title: "save",
                action: onSavePressed
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(generatedImage == nil ? 0.5 : 1)
            .disabled(generatedImage == nil)
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
                            onGeneraImagePressed()
                        }
                        .opacity(isGenerating ? 0 : 1)
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGenerating ? 1 : 0)
                }
                .disabled(isGenerating || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay(content: {
                        ZStack {
                            if let generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            }
                        }
                    })
                    .clipShape(.circle)
            }
            .removeListRowFormatting()
        }
    }
    
    private var attributeSection: some View {
        Section {
            Picker("is a ...".capitalized, selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("this is ...".capitalized)
            }
            
            Picker(selection: $characterLocation) {
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
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("name your avatar*")
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.press) {
                onBackButtonPressed()
            }
    }
    
    // MARK: -- Function
    private func onBackButtonPressed() {
        dismiss()
    }
    
    private func onGeneraImagePressed() {
        isGenerating = true
        Task {
            defer {
                isGenerating = false
            }
            try? await Task.sleep(for: .seconds(3))
            generatedImage = UIImage(systemName: "star.fill")
        }
    }
    
    private func onSavePressed() {
        isSaving = true
        Task {
            defer {
                isSaving = false
            }
            try? await Task.sleep(for: .seconds(3))
            dismiss()
        }
    }
}

#Preview {
    CreateAvatarView()
}
