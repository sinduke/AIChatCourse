//
//  DevSettingsView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/27/25.
//

import SwiftUI
/**
 MVVM (5/6)
 */

struct DevSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AuthManager.self) private var authManager
    @Environment(UserManager.self) private var userManager
    @Environment(ABTestManager.self) private var abTestManager
    
    @State private var createAccountTest: Bool = false
    @State private var onBoardingCommunityTest: Bool = false
    @State private var categoryRowTest: CategoryRowTestOption = .default
    
    // MARK: -- View
    var body: some View {
        NavigationStack {
            List {
                abTestSection
                authSection
                userSection
                deviceSection
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    backButtonView
                }
            })
            .onFirstAppear {
                loadABTest()
            }
            .screenAppearAnalytics(name: "DevSettings")
            .navigationTitle("DevSettings 🧑‍💻")
        }
    }
    
    private var backButtonView: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.black)
            .anyButton {
                onBackButtonPressed()
            }
    }
    
    private var deviceSection: some View {
        Section {
            let array = Utilities.eventParameters.sortedKeyValuePairs()
            
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
            
        } header: {
            Text("Device Info")
        }
    }
    
    private var userSection: some View {
        Section {
            let array = userManager.currentUser?.eventParameters.sortedKeyValuePairs() ?? []
            
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
            
        } header: {
            Text("User Info")
        }
    }
    
    private var authSection: some View {
        Section {
            let array = authManager.auth?.eventParameters.sortedKeyValuePairs() ?? []
            
            ForEach(array, id: \.key) { item in
                itemRow(item: item)
            }
            
        } header: {
            Text("Auth Info")
        }
    }
    
    private var abTestSection: some View {
        Section {
            Toggle("Create Acc Test", isOn: $createAccountTest)
                .onChange(of: createAccountTest, handleCreateAccountChange)
            
            Toggle("OnB Community Test", isOn: $onBoardingCommunityTest)
                .onChange(of: onBoardingCommunityTest, handleonBoardingCommunityChange)
            
            Picker("Category", selection: $categoryRowTest) {
                ForEach(CategoryRowTestOption.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .id(category)
                }
            }
        } header: {
            Text("ABTest")
        }
        .font(.caption)
    }
    
    // MARK: -- FuncView
    private func itemRow(item: (key: String, value: Any)) -> some View {
        HStack {
            Text(item.key)
            Spacer(minLength: 4)
            if let value = String.convertToString(item.value) {
                Text(value)
            } else {
                Text("Unknown")
            }
        }
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.3)
    }
    
    // MARK: -- Func --
    private func handleCreateAccountChange(oldValue: Bool, newValue: Bool) {
        
        updateTest(
            property: &createAccountTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.createAccountTest,
            updateAction: { tests in
                tests.update(createAccountTest: newValue)
            }
        )
    }
    
    private func handleonBoardingCommunityChange(oldValue: Bool, newValue: Bool) {
        
        updateTest(
            property: &onBoardingCommunityTest,
            newValue: newValue,
            savedValue: abTestManager.activeTests.onBoardingCommunityTest,
            updateAction: { tests in
                tests.update(onBoardingCommunityTest: newValue)
            }
        )
    }
    
    private func updateTest(
        property: inout Bool,
        newValue: Bool,
        savedValue: Bool,
        updateAction: (inout ActiveABTests) -> Void
    ) {
        if newValue != savedValue {
            do {
                var test = abTestManager.activeTests
                updateAction(&test)
                try abTestManager.override(updateTest: test)
            } catch {
                property = savedValue
            }
        }
    }
    
    private func loadABTest() {
        createAccountTest = abTestManager.activeTests.createAccountTest
        onBoardingCommunityTest = abTestManager.activeTests.onBoardingCommunityTest
        categoryRowTest = abTestManager.activeTests.categoryRowTest
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
}

#Preview {
    DevSettingsView()
        .previewEnvrionment()
}
