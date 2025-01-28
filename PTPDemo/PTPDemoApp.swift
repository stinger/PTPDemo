//
//  PTPDemoApp.swift
//  PTPDemo
//
//  Created by Ilian Konchev on 28.01.25.
//

import SwiftUI

@main
struct PTPDemoApp: App {
    var body: some Scene {
        WindowGroup {
            MainView(model: .init(mpcClient: .init()))
        }
    }
}
