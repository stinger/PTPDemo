//
//  MainModel.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import Observation
import OSLog

enum Destination: Hashable {
    case lookup
    case game(Player)
    case profile
}

@MainActor
@Observable
class MainModel {
    let mpcClient: MPCClient
    var path: [Destination] = []

    @ObservationIgnored private var sessionStarted: Bool = false

    var invitationRequest: InvitationRequest?
    init(mpcClient: MPCClient, invitationRequest: InvitationRequest? = nil) {
        self.mpcClient = mpcClient
        self.invitationRequest = invitationRequest

        mpcClient.onPlayerInvite = { [weak self] request in
            guard let self else { return }
            os_log(
                .debug,
                "Prompting user to accept peer invite from %@",
                request.peerID.displayName
            )
            self.invitationRequest = request
        }
    }

    func sendInvitationResponse(_ response: Bool) {
        mpcClient.sendInvitationResponse(response)
    }

    func startSession(with username: String) {
        guard !sessionStarted else { return }
        sessionStarted = true
        mpcClient.startSession(with: username)
    }
}
