import SwiftUI

struct HomeView: View {
    @StateObject private var gameState = GameState()
    @State private var playerName: String = "Player"
    @State private var showingGameView = false
    @State private var showingNameChangeView = false
    @State private var isGameSaved = false

    var body: some View {
        NavigationView {
            ZStack {
                // Animated Background
                AnimatedBackgroundView()
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Main title
                    Text("Bienvenue à Charivari des mots")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 5)

                    // Button for "Start New Game" or "Continue Game"
                    Button(action: {
                        // If a game is saved, load the game, otherwise start a new game
                        if isGameSaved {
                            gameState.loadGameState()  // Load the saved game state
                        } else {
                            gameState.reset()
                            Task {
                                await gameState.fetchNewWord()  // Only fetch a new word for a new game
                            }
                        }
                        showingGameView = true
                    }) {
                        Text(isGameSaved ? "Continuer la partie" : "Commencer une partie")
                            .font(.headline)
                            .padding()
                            .background(isGameSaved ? Color.yellow : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Navigation link to GameView when showingGameView is true
                    NavigationLink("", destination: GameView(gameState: gameState), isActive: $showingGameView)

                    // Navigate to ScoresView
                    NavigationLink(destination: ScoresView()) {
                        Text("Afficher les scores")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    // Button to change the player name
                    Button(action: {
                        showingNameChangeView = true
                    }) {
                        Text("Changer votre nom")
                            .font(.headline)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $showingNameChangeView) {
                        NameChangeView(playerName: $playerName)
                    }

                    Spacer()
                }
                .navigationTitle("Menu Principal")
                .navigationBarHidden(true)
                .onAppear {
                    
                    checkSavedGameState()
                    if !isGameSaved {
                        gameState.reset() // Reset the game if it's a new session
                        Task {
                            await gameState.fetchNewWord()
                        }
                    }
                }

                


            }
        }
    }
    // Function to check if a saved game exists and update the state
    private func checkSavedGameState() {
        isGameSaved = gameState.isGameSaved()

        // Load the saved game state if it exists
        if isGameSaved {
            gameState.loadGameState()
        } else {
            gameState.reset()
        }
    }
}


import SwiftUI

struct NameChangeView: View {
    @Binding var playerName: String
    @State private var newName: String = ""

    var body: some View {
        VStack {
            Text("Changer votre nom")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            TextField("Nouveau nom", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Valider") {
                if !newName.isEmpty {
                    playerName = newName
                }
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
    }
}
