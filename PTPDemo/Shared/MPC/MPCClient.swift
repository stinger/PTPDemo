//
//  MPCClient.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import MultipeerConnectivity
import OSLog

class MPCClient {
    var session: MPCSession?
    var peerDisplayName: String = "Unknown"

    func startSession(with displayName: String) {
        peerDisplayName = displayName

        session = MPCSession(localPeerDisplayName: peerDisplayName)
    }

    func updatePeerDisplayName(_ displayName: String) {
        os_log(.debug, "Update peer display name")
        peerDisplayName = displayName
        if let session {
            session.updatePeerDisplayName(peerDisplayName)
        }
    }
}
