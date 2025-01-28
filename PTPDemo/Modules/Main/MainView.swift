//
//  MainView.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

struct MainView: View {
    @Bindable var model: MainModel

    var body: some View {
        NavigationStack(path: $model.path) {
            Text("PTPDemo")
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
