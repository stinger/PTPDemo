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
                        model.path.append(.lookup)
                    },
                    label: {
                        Label("Find players", systemImage: "person.line.dotted.person")
                            .labelStyle(.titleOnly)
                    }
                )
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Welcome, \(username)!")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu(
                        content: {
                            Button(action: {
                                model.path.append(.profile)
                            }) {
                                Label("Profile", systemImage: "person.wave.2")
                            }
                        },
                        label: {
                            Image(systemName: "gear")
                                .contentShape(Rectangle())
                        })
                }
            }
            .onChange(of: username) { _, newValue in
                model.mpcClient.updatePeerDisplayName(newValue)
            }
            .onAppear {
                model.startSession(with: username)
            }
            .alert(item: $model.invitationRequest) { request in
                Alert(
                    title: Text("Game Request"),
                    message: Text(
                        "\(request.peerID.displayName) wants to play TicTacToe with you."),
                    primaryButton: .default(
                        Text("Join"),
                        action: {
                            model.sendInvitationResponse(true)
                            withAnimation {
                                model.path = [.game(request.player)]
                            }
                        }),
                    secondaryButton: .cancel(
                        Text("Cancel"),
                        action: {
                            model.sendInvitationResponse(false)
                        })
                )
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .lookup:
                    LookupView(
                        model: .init(
                            mpcClient: model.mpcClient
                        ),
                        username: $username,
                        path: $model.path
                    )
                case .game(let player):
                    GameView(model: .init(mpcClient: model.mpcClient, player: player))
                case .profile:
                    ProfileView(username: $username)
                }
            }
        }
    }
}

#Preview {
    MainView(model: .init(mpcClient: .init()))
}
