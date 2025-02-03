//
//  LookupModel.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 29.01.25.
//

import MultipeerConnectivity
import OSLog
import Observation

@Observable
class LookupModel {
    var peers: [MCPeerID] = []
    var mpcClient: MPCClient
    var mcBrowser: MCNearbyServiceBrowser?
    var delegate: MCNearbyServiceBrowserDelegateWrapper?

    init(mpcClient: MPCClient) {
        self.mpcClient = mpcClient
    }

    func lookup(onConnect: @escaping (MCPeerID) -> Void) {
        os_log(.debug, "Lookup initiated...")
        if mpcClient.session == nil {
            os_log(.debug, "No session available, starting session...")
            mpcClient.startSession(with: mpcClient.peerDisplayName)
        }

        guard let session = mpcClient.session else { return }

        session.peerConnectedHandler = { [weak self] peerID in
            guard let self else { return }
            mpcClient.connectedToPeer(peer: peerID, state: .init(activePlayer: .host))
            peers = []
            os_log(.debug, "Connected to %@", peerID.displayName)
            mcBrowser?.stopBrowsingForPeers()
            onConnect(peerID)
        }

        os_log(.debug, "Initializing browser...")
        mcBrowser = .init(
            peer: session.localPeerID,
            serviceType: session.sessionConfiguration.serviceType
        )
        delegate = .init(
            mpcClient: mpcClient,
            onPeerFound: { [weak self] peerId in
                guard let self else { return }
                if !peers.contains(peerId) {
                    peers.append(peerId)
                }
            },
            onPeerLost: { [weak self] peerId in
                guard let self else { return }
                peers.removeAll(where: { $0 == peerId })
            }
        )
        mcBrowser?.delegate = delegate
        os_log(.debug, "Start browsing for peers...")
        mcBrowser?.startBrowsingForPeers()
    }

    func invite(_ peerID: MCPeerID) {
        os_log(.debug, "Inviting peer: %@", peerID.displayName)
        guard
            let session = mpcClient.session?.mcSession,
            let playerData = try? JSONEncoder().encode(Player.guest)
        else {
            return
        }

        mcBrowser?.invitePeer(peerID, to: session, withContext: playerData, timeout: 40)
    }
}

// MARK: - `MCNearbyServiceBrowserDelegate`.
class MCNearbyServiceBrowserDelegateWrapper: NSObject, MCNearbyServiceBrowserDelegate {
    var mpcClient: MPCClient
    var onPeerFound: (MCPeerID) -> Void = { _ in }
    var onPeerLost: (MCPeerID) -> Void = { _ in }

    init(
        mpcClient: MPCClient, onPeerFound: @escaping (MCPeerID) -> Void,
        onPeerLost: @escaping (MCPeerID) -> Void
    ) {
        self.mpcClient = mpcClient
        self.onPeerFound = onPeerFound
        self.onPeerLost = onPeerLost
    }

    deinit {
        os_log("Browser delegate deinit")
    }

    func browser(
        _ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        os_log(.debug, "Found peer: %@", peerID.displayName)
        guard
            let identityValue = info?[MPCSessionConstants.kKeyIdentity],
            let session = mpcClient.session
        else {
            return
        }

        if identityValue == session.sessionConfiguration.sessionIdentity {
            onPeerFound(peerID)
        }
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        os_log(.debug, "Lost peer: %@", peerID.displayName)
        onPeerLost(peerID)
    }
}
