//
//  Player+Color.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

extension Player {
    var color: Color {
        switch self {
        case .host: return .blue
        case .guest: return .green
        }
    }
}

extension Color {
    static let systemBackground: Self = .init(UIColor.systemBackground)
    static let separator: Self = .init(UIColor.separator)
}
