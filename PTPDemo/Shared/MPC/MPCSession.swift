//
//  MPCSession.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import MultipeerConnectivity
import OSLog

struct MPCSessionConstants {
    static let kKeyIdentity: String = "identity"
}

struct MPCSessionConfiguration {
    let serviceType: String
    let sessionIdentity: String
    let maxNumberOfPeers: Int
}

class MPCSession: NSObject {
    var localPeerID: MCPeerID
    var mcSession: MCSession
    let sessionConfiguration: MPCSessionConfiguration

    var peerDataHandler: ((Data, MCPeerID) -> Void)?
    var peerInvitationHandler: ((Data?, MCPeerID) -> Void)?
    var serviceInvitationHandler: ((Bool, MCSession?) -> Void)?

    private var mcAdvertiser: MCNearbyServiceAdvertiser

    init(sessionConfiguration: MPCSessionConfiguration, localPeerDisplayName: String) {
        os_log(.debug, "Multipeer service init")
        self.sessionConfiguration = sessionConfiguration
        localPeerID = .init(displayName: localPeerDisplayName)

        mcSession = .init(
            peer: localPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        mcAdvertiser = .init(
            peer: localPeerID,
            discoveryInfo: [
                MPCSessionConstants.kKeyIdentity: sessionConfiguration.sessionIdentity
            ],
            serviceType: sessionConfiguration.serviceType
        )

        super.init()
        mcSession.delegate = self
        mcAdvertiser.delegate = self
    }

    func start() {
        os_log(.debug, "Start advertising peer")
        mcAdvertiser.startAdvertisingPeer()
    }

    func suspend() {
        os_log(.debug, "Stop advertising peer")
        mcAdvertiser.stopAdvertisingPeer()
    }

    func invalidate() {
        os_log(.debug, "Invalidate session")
        suspend()
        mcSession.disconnect()
    }

    func updatePeerDisplayName(_ displayName: String) {
        os_log(.debug, "Updating peer display name")
        invalidate()

        localPeerID = .init(displayName: displayName)
        mcSession = .init(
            peer: localPeerID, securityIdentity: nil, encryptionPreference: .required)
        mcAdvertiser = .init(
            peer: localPeerID,
            discoveryInfo: [
                MPCSessionConstants.kKeyIdentity: sessionConfiguration.sessionIdentity
            ],
            serviceType: sessionConfiguration.serviceType
        )
        start()
    }

    func receiveInvitationResponse(_ response: Bool) {
        serviceInvitationHandler?(response, mcSession)
        serviceInvitationHandler = nil
    }

    var peerConnectedHandler: ((MCPeerID) -> Void)?
    private func peerConnected(peerID: MCPeerID) {
        os_log(.debug, "Peer connected %@", peerID.displayName)
        if let handler = peerConnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
        if mcSession.connectedPeers.count == sessionConfiguration.maxNumberOfPeers {
            self.suspend()
        }
    }

    var peerDisconnectedHandler: ((MCPeerID) -> Void)?
    private func peerDisconnected(peerID: MCPeerID) {
        os_log(.debug, "Peer disconnected %@", peerID.displayName)
        if let handler = peerDisconnectedHandler {
            DispatchQueue.main.async {
                handler(peerID)
            }
        }
    }

    func sendDataToAllPeers(data: Data) {
        os_log(.debug, "Sending data to all peers")
        sendData(data: data, peers: mcSession.connectedPeers, mode: .reliable)
    }

    func sendData(data: Data, peers: [MCPeerID], mode: MCSessionSendDataMode) {
        os_log(.debug, "Sending data to specific peers")
        do {
            try mcSession.send(data, toPeers: peers, with: mode)
        } catch let error {
            NSLog("Error sending data: \(error)")
        }
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
        switch state {
        case .connected:
            peerConnected(peerID: peerID)
        case .notConnected:
            peerDisconnected(peerID: peerID)
        case .connecting:
            break
        @unknown default:
            fatalError("Unhandled MCSessionState")
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        os_log(.debug, "Received data from peer %@", peerID.displayName)
        if let handler = peerDataHandler {
            DispatchQueue.main.async {
                handler(data, peerID)
            }
        }
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

// MARK: - `MCNearbyServiceAdvertiserDelegate`.
extension MPCSession: MCNearbyServiceAdvertiserDelegate {
    public func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        os_log(.debug, "Received invitation from peer %@", peerID.displayName)
        serviceInvitationHandler = invitationHandler

        if self.mcSession.connectedPeers.count < sessionConfiguration.maxNumberOfPeers {
            peerInvitationHandler?(context, peerID)
        }
    }
}
