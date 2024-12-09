//
//  Array.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-30.
//

// Array+SafeSubscript.swift
import Foundation

// Extension de sous-index sécurisé pour éviter les plantages dus à un indice hors limites
extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
