//
//  LookupView.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 29.01.25.
//

import SwiftUI

struct LookupView: View {
    var model: LookupModel
    @Binding var username: String
    @Binding var path: [Destination]

    var body: some View {
        List {
            Section("Available players") {
                ForEach(model.peers, id: \.displayName) { peer in
                    LabeledContent("\(peer.displayName)") {
                        Button("Invite") {
                            model.invite(peer)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Reload") {
                    model.lookup { _ in
                        path = [.game(.host)]
                    }
                }
            }
        }
        .listStyle(.plain)
        .onAppear {
            model.lookup { _ in
                path = [.game(.host)]
            }
        }
        .navigationTitle("Find a player")
    }
}

#Preview {
    NavigationStack {
        LookupView(
            model: LookupModel(mpcClient: .init()), username: .constant("Bruce Wayne"),
            path: .constant([]))
    }
}
