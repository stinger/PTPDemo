//
//  MainModel.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import Observation

enum Destination: Hashable {
    case game(Player)
}

@MainActor
@Observable
class MainModel {
    var path: [Destination] = []

    init() {
        path = [.game(.host)]
    }
}
