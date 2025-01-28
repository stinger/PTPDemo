//
//  Player.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//
import SwiftUI

enum Player: Codable, Hashable, CustomStringConvertible {
    case host
    case guest

    func toggle() -> Player {
        switch self {
        case .host: return .guest
        case .guest: return .host
        }
    }

    var indicator: String {
        switch self {
        case .host: return "xmark"
        case .guest: return "circle"
        }
    }

    var description: String {
        switch self {
        case .host: return "host"
        case .guest: return "guest"
        }
    }
}
