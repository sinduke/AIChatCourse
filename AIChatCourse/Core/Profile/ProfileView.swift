//
//  ProfileView.swift
//  AIChatCourse
//
//  Created by sinduke on 5/15/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var showSettingView: Bool = false
    var body: some View {
        NavigationStack {
            Text("ProfileView")
                .navigationTitle("ProfileNavTitle")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingButton
                    }
                }
        }
        .sheet(isPresented: $showSettingView) {
            Text("SettingView")
        }
    }

    private var settingButton: some View {
        Button {
            onSettingButtonPressed()
        } label: {
            Image(systemName: "gear")
                .font(.headline)
        }
    }

    private func onSettingButtonPressed() {
        showSettingView = true
    }

}

#Preview {
    ProfileView()
}
