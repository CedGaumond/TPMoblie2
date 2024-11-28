import SwiftUI

// Home Screen View (Main Menu)
// Home Screen View (Main Menu)
struct HomeView: View {
    @StateObject private var gameState = GameState()  // Initialize GameState
    @State private var playerName: String = "Player"
    @State private var showingGameView = false
    @State private var showingNameChangeView = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Bienvenue à Charivari des mots")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Button to start the game
                NavigationLink(destination: GameView(gameState: gameState), isActive: $showingGameView) {
                    Button(action: {
                        showingGameView = true
                    }) {
                        Text("Commencer une partie")
                            .font(.headline)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }

                // Simplify the button to show scores view
                NavigationLink(destination: ScoresView()) {
                    Text("Afficher les scores")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Button to change player's name
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
                    NameChangeView(playerName: $playerName)  // Sheet to change name
                }
                
                Spacer()
            }
            .navigationTitle("Menu Principal")
            .navigationBarHidden(true)  // Hide navigation bar on the home screen
            .onAppear {
                // Fetch a new word if needed when the Home view appears
                Task {
                    await gameState.fetchNewWord()
                }
            }
        }
    }
}


// Name Change View
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
