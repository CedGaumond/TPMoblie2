import Foundation
class SolvedWordsManager {
    static let shared = SolvedWordsManager()
    private let solvedWordsKey = "solvedWords" // Key for storing solved words in UserDefaults

    // Function to save a solved word in UserDefaults
    func saveSolvedWord(word: String, secret: String, time: Int, score: Int) {
        // Load the existing solved words from UserDefaults
        var solvedWords = loadSolvedWords()
        
        // Create a Word object
        let solvedWord = SolvedWord(word: Word(word: word, secret: secret), time: time, score: score)
        
        // Append the solved word to the list
        solvedWords.append(solvedWord)
        
        // Save the updated list back to UserDefaults
        if let encodedData = try? JSONEncoder().encode(solvedWords) {
            UserDefaults.standard.set(encodedData, forKey: solvedWordsKey)
        }
    }

    // Function to load the solved words from UserDefaults
    func loadSolvedWords() -> [SolvedWord] {
        // Return the list of solved words or an empty list if no data is available
        if let savedData = UserDefaults.standard.data(forKey: solvedWordsKey),
           let decodedWords = try? JSONDecoder().decode([SolvedWord].self, from: savedData) {
            return decodedWords
        }
        return []
    }

    // Function to clear all solved words from UserDefaults
    func clearSolvedWords() {
        UserDefaults.standard.removeObject(forKey: solvedWordsKey)
    }
}
