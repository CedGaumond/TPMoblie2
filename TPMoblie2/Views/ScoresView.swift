import SwiftUI

struct ScoresView: View {
    @State private var solvedWords: [SolvedWord] = []  // Array of SolvedWord objects
    @State private var selectedWordScores: [Score] = []  // Scores for a selected word
    @State private var isScoreViewVisible = false  // Toggle visibility of score view for a word
    @State private var showingResetConfirmation = false  // State to control the alert for reset confirmation
    @State private var isLoadingScores = false  // Loading state to show a loading indicator

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
                        Text(solvedWord.word.word)  // Display the word
                        Spacer()
                        Text("\(solvedWord.time) seconds")  // Display the time spent on the word
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Points: \(solvedWord.score)")  // Display the score
                            .foregroundColor(.green)
                    }
                    .onTapGesture {
                        // When a word is tapped, fetch the scores for this word and show the score view
                        fetchScoresForWord(solvedWord.word.word)
                    }
                }
                .navigationTitle("Solved Words")
                .onAppear {
                    loadSolvedWords()  // Load solved words when the view appears
                }
                
                if isLoadingScores {
                    ProgressView("Loading Scores...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
            .navigationBarItems(trailing: Button(action: {
                // Show confirmation dialog before resetting
                showingResetConfirmation = true
            }) {
                Image(systemName: "trash")  // Use trash icon for reset
                    .imageScale(.large)
            })
            .alert(isPresented: $showingResetConfirmation) {
                Alert(
                    title: Text("Êtes-vous sûr ?"),
                    message: Text("This will reset all the solved words."),
                    primaryButton: .destructive(Text("Reset")) {
                        resetSolvedWords()  // Reset the solved words if confirmed
                    },
                    secondaryButton: .cancel()
                )
            }
            .sheet(isPresented: $isScoreViewVisible) {
                // Display scores for the selected word only when scores are available
                ScoreDetailsView(scores: selectedWordScores)
            }
        }
    }

    // Function to load the solved words from SolvedWordsManager
    private func loadSolvedWords() {
        let loadedWords = SolvedWordsManager.shared.loadSolvedWords()
        solvedWords = loadedWords
    }

    // Fetch scores for a word from the server
    private func fetchScoresForWord(_ word: String) {
        isLoadingScores = true  // Set loading state to true
        Task {
            do {
                // Fetch scores for the word asynchronously
                let scores = try await NetworkService.getScores(for: word)
                
                // Update the scores and show the sheet
                DispatchQueue.main.async {
                    self.selectedWordScores = scores.list  // Update the scores list
                    self.isLoadingScores = false  // Stop loading indicator
                    if !self.selectedWordScores.isEmpty {
                        self.isScoreViewVisible = true  // Show the score details sheet
                    }
                }
            } catch {
                print("Error fetching scores: \(error)")
                DispatchQueue.main.async {
                    self.isLoadingScores = false  // Stop loading indicator if there's an error
                }
            }
        }
    }

    // Function to reset all solved words
    private func resetSolvedWords() {
        solvedWords = []
        SolvedWordsManager.shared.clearSolvedWords()
    }
}
