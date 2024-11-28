//
//  Word.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import Foundation

// The Word struct is unchanged
struct Word: Codable, Equatable, Hashable {
    let word: String
    let secret: String

    enum CodingKeys: String, CodingKey {
        case word = "Word"
        case secret = "Secret"
    }
}

// Update the SolvedWord struct to have the correct properties
struct SolvedWord: Codable {
    let word: Word  // Store the entire Word struct
    let time: Int
}







