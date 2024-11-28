import SwiftUI

struct ScoresView: View {
    @State private var solvedWords: [SolvedWord] = []  // Array of SolvedWord objects

    var body: some View {
        NavigationView {
            VStack {
                if solvedWords.isEmpty {
                    Text("No solved words yet.")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // List to show all solved words
                List(solvedWords, id: \.word.word) { solvedWord in
                    HStack {
                        Text(solvedWord.word.word)  // Display the scrambled word
                        Spacer()
                        Text("\(solvedWord.time) seconds")  // Display the time spent on the word
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Solved Words")
                .onAppear {
                    print("Entered ScoresView")  // Print message when entering ScoresView
                    loadSolvedWords()
                }
            }
        }
    }

    // Function to load the solved words from SolvedWordsManager
    private func loadSolvedWords() {
        // Load solved words from SolvedWordsManager
        let loadedWords = SolvedWordsManager.shared.loadSolvedWords()
        
        // Debugging: Print all solved words to the console
        if loadedWords.isEmpty {
            print("No solved words found.")
        } else {
            for solvedWord in loadedWords {
                print("Loaded Word: \(solvedWord.word.word), Secret: \(solvedWord.word.secret), Time: \(solvedWord.time) seconds")
            }
        }

        // Assign loaded words to the state variable
        solvedWords = loadedWords
    }
}
