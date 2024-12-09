//
//  ScoreDetailsView.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-30.
//
import SwiftUI

struct ScoreDetailsView: View {
    let scores: [Score]  // The list of players and their scores for a word
    
    var body: some View {
        NavigationStack {
            VStack {
                if scores.isEmpty {
                    Text("No scores yet for this word.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // List to show the player names and their scores
                List(scores, id: \.player) { score in
                    HStack {
                        Text(score.player)  // Display player name
                        Spacer()
                        Text("Score: \(score.score)")  // Display score
                            .foregroundColor(.green)
                    }
                }
                .navigationTitle("Player Scores")
                .padding()
            }
        }
    }
}
