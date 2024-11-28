//
//  Score.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import Foundation

struct Score: Codable {
    let player: String
    let score: Int
}

struct ScoreList: Codable {
    let list: [Score]
}

