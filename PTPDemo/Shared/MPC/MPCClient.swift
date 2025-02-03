//
//  MPCClient.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import MultipeerConnectivity
import OSLog

struct InvitationRequest: Identifiable {
    var id: UUID = .init()
    var peerID: MCPeerID
    var player: Player
}

class MPCClient {
    var session: MPCSession?
    var peerDisplayName: String = "Unknown"

    var onPlayerInvite: ((InvitationRequest) -> Void)?

    func startSession(with displayName: String) {
        peerDisplayName = displayName
        os_log(.debug, "Starting session with display name of %@", peerDisplayName)
        if session != nil {
            session?.invalidate()
        }

        let configuration: MPCSessionConfiguration = .init(
            serviceType: "sample",
            sessionIdentity: "com.sparkledev.ptpdemo.sample",
            maxNumberOfPeers: 1
        )
        session = MPCSession(
            sessionConfiguration: configuration,
            localPeerDisplayName: peerDisplayName
        )

        session?.peerInvitationHandler = { [weak self] data, peer in
            guard
                let data,
                let player = try? JSONDecoder().decode(Player?.self, from: data)
            else {
                return
            }
            self?.onPlayerInvite?(.init(peerID: peer, player: player))
        }

        session?.start()
    }

    func sendInvitationResponse(_ response: Bool) {
        session?.receiveInvitationResponse(response)
    }

    func updatePeerDisplayName(_ displayName: String) {
        os_log(.debug, "Update peer display name")
        guard !displayName.isEmpty else { return }
        peerDisplayName = displayName
        if let session {
            session.updatePeerDisplayName(peerDisplayName)
        }
    }
}
