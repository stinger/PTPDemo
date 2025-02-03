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

    let client: MPCClient

    init(mpcClient: MPCClient, player: Player) {
        client = mpcClient
        assignedPlayer = player
        state = .init(activePlayer: player)

        bindToPeer()
    }

    func moveInitiated(at index: Int) {
        guard let state = state.moveInitiated(at: index) else { return }
        assignedPlayer = state.activePlayer
        client.share(state)
    }

    func reset() {
        state = .init(activePlayer: .host)
        assignedPlayer = state.activePlayer
        client.share(state)
    }

    func bindToPeer() {
        client.onStateUpdate = { [weak self] state in
            self?.state = state
        }
    }
}
