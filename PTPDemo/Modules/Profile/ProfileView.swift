//
//  ProfileView.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var username: String

    var body: some View {
        List {
            Section("Player name") {
                TextField("Enter your player name", text: $username)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(username: .constant("Bruce Wayne"))
    }
}
