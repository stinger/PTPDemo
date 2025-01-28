//
//  MainView.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

struct MainView: View {
    @Bindable var model: MainModel
    @AppStorage("username") var username: String = "[Unknown]"

    var body: some View {
        NavigationStack(path: $model.path) {
            VStack {
                Spacer()

                Image(systemName: "person.2.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80, alignment: .center)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .padding(.top, -100)

                Text("No players found yet")
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                Spacer()

                Text(
                    "Tap the button below to scan for players to invite,\nor wait for an invitation."
                )
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)

            }
            .padding(.horizontal)
            .safeAreaInset(edge: .bottom) {
                Button(
                    action: {
                        model.path.append(.game(.host))
                    },
                    label: {
                        Label("Find players", systemImage: "person.line.dotted.person")
                            .labelStyle(.titleOnly)
                    }
                )
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Welcome, \(username)!")
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .game(let player):
                    GameView(model: .init(player: player))
                }
            }
        }
    }
}

#Preview {
    MainView(model: .init())
}
