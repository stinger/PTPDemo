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

        session?.peerDataHandler = { [weak self] data, peer in
            self?.dataReceivedHandler(data: data, peer: peer)
        }

        session?.peerConnectedHandler = { [weak self] peer in
            self?.connectedToPeer(peer: peer)
        }

        session?.peerDisconnectedHandler = { [weak self] peer in
            self?.disconnectedFromPeer(peer: peer)
        }

        session?.start()
    }

    func restartSession() {
        guard let session else { return }
        startSession(with: session.localPeerID.displayName)
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

    var connectedPeer: MCPeerID?
    func connectedToPeer(peer: MCPeerID) {
        if connectedPeer != nil {
            fatalError("Already connected to a peer.")
        }

        connectedPeer = peer
        peerDisplayName = peer.displayName
    }

    func connectedToPeer(peer: MCPeerID, state: GameState) {
        if connectedPeer != nil {
            fatalError("Already connected to a peer.")
        }

        share(state)

        connectedPeer = peer
        peerDisplayName = peer.displayName
    }
    
    var onPeerDisconnect: ((MCPeerID) -> Void)?
    func disconnectedFromPeer(peer: MCPeerID) {
        if connectedPeer == peer {
            connectedPeer = nil
        }
        session?.invalidate()
        onPeerDisconnect?(peer)
    }

    func share(_ state: GameState) {
        guard let encodedData = try? JSONEncoder().encode(state) else {
            fatalError("Unexpectedly failed to encode the moves.")
        }
        session?.sendDataToAllPeers(data: encodedData)
    }

    var onStateUpdate: ((GameState) -> Void)?
    func dataReceivedHandler(data: Data, peer: MCPeerID) {
        guard let state = try? JSONDecoder().decode(GameState.self, from: data) else {
            fatalError("Unexpectedly failed to decode game state.")
        }
        receiveState(state, from: peer)
    }

    func receiveState(_ state: GameState, from peer: MCPeerID) {
        if connectedPeer != peer {
            fatalError("Received moves from unexpected peer.")
        }

        // do something with state
        onStateUpdate?(state)
    }
}
