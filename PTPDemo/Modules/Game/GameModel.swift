//
//  GameModel.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import Foundation

@MainActor
@Observable
class GameModel {
    var state: GameState
    var assignedPlayer: Player

    init(player: Player) {
        assignedPlayer = player
        state = .init(activePlayer: player)
    }

    func moveInitiated(at index: Int) {
        guard let state = state.moveInitiated(at: index) else { return }
        assignedPlayer = state.activePlayer
        _ = state.checkWinner()
    }

    func reset() {
        state = .init(activePlayer: .host)
        assignedPlayer = state.activePlayer
    }

}
