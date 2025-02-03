//
//  GameView.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

struct GameView: View {
    let model: GameModel
    let col = Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)

    var screenTitle: String {
        guard let winner = model.state.winner else { return "TicTacToe" }
        if winner == model.assignedPlayer {
            return "\(winner.description) wins!"
        } else {
            return "\(winner.description) wins!"
        }
    }

    var body: some View {
        VStack {
            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("Player: ")

                Image(systemName: model.assignedPlayer.indicator)
                    .foregroundStyle(model.assignedPlayer.color)
            }

            Text(model.assignedPlayer == model.state.activePlayer ? "Your turn" : "Waiting...")

            Spacer()

            LazyVGrid(columns: col, spacing: 1) {
                ForEach(Array(zip(model.state.moves.indices, model.state.moves)), id: \.0) { index, move in
                    Color.systemBackground
                        .overlay {
                            if let move {
                                Image(systemName: move.player.indicator)
                                    .foregroundStyle(move.player.color)
                                    .transition(.opacity)
                                    .animation(.default, value: index)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1.0, contentMode: .fit)
                        .font(.largeTitle)
                        .onTapGesture {
                            model.moveInitiated(at: index)
                        }
                }
            }
            .background(Color.separator)
            .padding(.horizontal)
            .padding(.vertical, 0)

            Spacer()

            if case Player.host = model.assignedPlayer {
                Button(action: {
                    model.reset()
                }) {
                    Text("Restart")
                }
                .buttonStyle(.borderedProminent)
            }

        }
        .navigationBarBackButtonHidden()
        .navigationTitle(screenTitle)
    }
}

#Preview {
    NavigationStack {
        GameView(model: .init(mpcClient: .init(), player: .host))
    }
}
