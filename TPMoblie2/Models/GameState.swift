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
    
    func startGame(word: Word) {
        currentWord = word
        letters = Array(word.word) 
        elapsedTime = 0
        isPlaying = true
        startTimer()
    }


    
    func fetchNewWord() async {
        do {
            let word = try await NetworkService.getNewWord()
            // Make sure to update UI on the main thread
            DispatchQueue.main.async {
                self.startGame(word: word)
            }
        } catch {
            print("Error fetching new word: \(error)")
        }
    }
    
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
