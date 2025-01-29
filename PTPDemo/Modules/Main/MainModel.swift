//
//  MainModel.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import Observation

enum Destination: Hashable {
    case lookup
    case game(Player)
    case profile
}

@MainActor
@Observable
class MainModel {
    let mpcClient: MPCClient
    var path: [Destination] = []

    @ObservationIgnored private var sessionStarted: Bool = false

    init(mpcClient: MPCClient) {
        self.mpcClient = mpcClient
    }

    func startSession(with username: String) {
        guard !sessionStarted else { return }
        sessionStarted = true
        mpcClient.startSession(with: username)
    }
}
