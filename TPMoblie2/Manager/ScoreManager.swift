//
//  ScoreManager.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-27.
//
import Foundation

class ScoreManager {
    
    // Key for accessing the scores in UserDefaults
    private static let scoresKey = "savedScores"
    
    // Load scores from UserDefaults
    static func loadScoresFromUserDefaults() -> [Score] {
        // Try to load data from UserDefaults
        guard let data = UserDefaults.standard.data(forKey: scoresKey),
              let savedScores = try? JSONDecoder().decode(ScoreList.self, from: data) else {
            return []  // Return an empty list if no data is found or decoding fails
        }
        return savedScores.list
    }
    
    // Save scores to UserDefaults
    static func saveScoresToUserDefaults(scores: [Score]) {
        let scoreList = ScoreList(list: scores)
        if let encoded = try? JSONEncoder().encode(scoreList) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
}

