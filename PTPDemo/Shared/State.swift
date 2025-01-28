//
//  State.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import Foundation

struct GameState: Codable {
    var moves: [Move?] = Array(repeating: nil, count: 9)
    var activePlayer: Player
    var winner: Player?

    mutating func moveInitiated(at index: Int) -> GameState? {
        if moves[index] == nil && winner == nil {
            moves[index] = .init(player: activePlayer, boardIndex: index)
            winner = checkWinner()
            activePlayer = activePlayer.toggle()
            return self
        }
        return nil
    }

    mutating func reset() {
        moves = Array(repeating: nil, count: 9)
        activePlayer = .host
        winner = nil
    }

    func checkWinner() -> Player? {
        let winningPatterns: Set<Set<Int>> = [
            [0, 1, 2],
            [3, 4, 5],
            [6, 7, 8],
            [0, 3, 6],
            [1, 4, 7],
            [2, 5, 8],
            [0, 4, 8],
            [2, 4, 6],
        ]

        let playerMoves = moves.compactMap { $0 }.filter { $0.player == activePlayer }
        let playerPositions = Set(playerMoves.map(\.boardIndex))

        for pattern in winningPatterns where pattern.isSubset(of: playerPositions) { return activePlayer }

        return nil
    }
}
