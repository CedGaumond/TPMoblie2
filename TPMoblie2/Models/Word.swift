//
//  Word.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import Foundation

struct Word: Codable, Equatable {  // Add Equatable conformance
    let word: String
    let secret: String
    
    // Use CodingKeys to map JSON keys to struct properties
    enum CodingKeys: String, CodingKey {
        case word = "Word"   // "Word" in JSON maps to `word` in the struct
        case secret = "Secret" // "Secret" in JSON maps to `secret` in the struct
    }

    // Equatable conformance is automatically synthesized by Swift
    // No need to manually implement the == operator unless you want custom comparison
}



