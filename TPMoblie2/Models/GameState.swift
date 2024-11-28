//
//  GameState.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import SwiftUI

class GameState: ObservableObject {
    @Published var currentWord: Word?
    @Published var letters: [Character] = []
    @Published var elapsedTime: TimeInterval = 0
    @Published var isPlaying = false
    private var timer: Timer?

    // Start a new game with a given word
    func startGame(word: Word) {
        currentWord = word
        letters = Array(word.word)  // Convert word into a list of characters
        elapsedTime = 0
        isPlaying = true
        startTimer()
    }

    // Fetch a new word and start the game with it
    func fetchNewWord() async {
        do {
            let word = try await NetworkService.getNewWord()
            DispatchQueue.main.async {
                self.startGame(word: word)
            }
        } catch {
            print("Error fetching new word: \(error)")
        }
    }

    // Reset the game state
    func reset() {
        currentWord = nil
        letters = []
        elapsedTime = 0
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }

    // Start the timer to track elapsed time
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.elapsedTime += 1
        }
    }

    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
}
