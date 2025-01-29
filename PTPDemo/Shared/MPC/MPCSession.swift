//
//  MPCSession.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import MultipeerConnectivity
import OSLog

class MPCSession: NSObject {
    var localPeerID: MCPeerID
    var mcSession: MCSession

    init(localPeerDisplayName: String) {
        localPeerID = .init(displayName: localPeerDisplayName)
        mcSession = .init(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )

        super.init()
        mcSession.delegate = self
    }

    func invalidate() {
        os_log(.debug, "Invalidate session")
        mcSession.disconnect()
    }

    func updatePeerDisplayName(_ displayName: String) {
        os_log(.debug, "Updating peer display name: %@")

        localPeerID = .init(displayName: displayName)
    }
}

// MARK: - `MCSessionDelegate`.
extension MPCSession: MCSessionDelegate {
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        os_log(.debug, "Session peer %@ changed state", peerID.displayName)
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        os_log(.debug, "Received data from peer %@", peerID.displayName)
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // pass
    }

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        // pass
    }

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // pass
    }
}
