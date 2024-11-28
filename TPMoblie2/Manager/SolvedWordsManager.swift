// Update the SolvedWordsManager to correctly save and load solved words
import SwiftUI
class SolvedWordsManager {
    static let shared = SolvedWordsManager()
    private let solvedWordsKey = "solvedWords" // Key for storing solved words in UserDefaults

    // Function to save a solved word in UserDefaults
    func saveSolvedWord(word: Word, time: Int) {
        var solvedWords = loadSolvedWords()  // Load existing solved words

        // Create a SolvedWord object to be saved
        let solvedWordEntry = SolvedWord(word: word, time: time)

        // Append the solved word entry to the list
        solvedWords.append(solvedWordEntry)

        // Save the updated list back to UserDefaults
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(solvedWords) {
            UserDefaults.standard.set(encoded, forKey: solvedWordsKey)
            print("Solved word saved: \(solvedWordEntry)")  // Debugging output
        }
    }

    func loadSolvedWords() -> [SolvedWord] {
        guard let data = UserDefaults.standard.data(forKey: solvedWordsKey),
              let decoded = try? JSONDecoder().decode([SolvedWord].self, from: data) else {
            print("No solved words found or failed to decode.")
            return []
        }
        return decoded
    }

}

