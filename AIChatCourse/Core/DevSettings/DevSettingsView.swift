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
        if newValue != abTestManager.activeTests.createAccountTest {
            do {
                var tests = abTestManager.activeTests
                tests.update(createAccountTest: newValue)
                try abTestManager.override(updateTest: tests)
            } catch {
                createAccountTest = abTestManager.activeTests.createAccountTest
            }
        }
    }
    
    private func loadABTest() {
        createAccountTest = abTestManager.activeTests.createAccountTest
    }
    
    private func onBackButtonPressed() {
        dismiss()
    }
    
}

#Preview {
    DevSettingsView()
        .previewEnvrionment()
}
