//
//  TPMoblie2App.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import SwiftUI

@main
struct TPMoblie2App: App {
    @StateObject private var gameState = GameState()  // Create and manage the game state

    var body: some Scene {
        WindowGroup {
            HomeView() 
        }
    }
}

