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

    init(localPeerDisplayName: String) {
        localPeerID = .init(displayName: localPeerDisplayName)
    }

    func updatePeerDisplayName(_ displayName: String) {
        os_log(.debug, "Updating peer display name: %@")

        localPeerID = .init(displayName: displayName)
    }
}
