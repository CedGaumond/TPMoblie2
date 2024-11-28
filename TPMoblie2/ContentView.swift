import SwiftUI

struct ContentView: View {
    @StateObject private var gameState = GameState()
    @State private var isScoresLinkActive = false  // Add this state to control the navigation
    
    var body: some View {
        NavigationView {
            VStack {
                if gameState.isPlaying {
                    GameView(gameState: gameState)
                } else {
                    Button("Start New Game") {
                        // Fetch a new word from the server
                        Task {
                            await gameState.fetchNewWord()
                        }
                    }
                }

                // You can optionally add a condition to activate the Scores link
                Button("Go to Scores") {
                    // Trigger the navigation when this button is pressed
                    isScoresLinkActive = true
                }
            }
            .navigationTitle("Charivari des mots")
            .navigationBarItems(trailing:
                NavigationLink(
                    destination: ScoresView(),
                    isActive: $isScoresLinkActive  // Use the binding to control navigation
                ) {
                    Text("Scores")
                }
            )
        }
    }
}
