import SwiftUI

// Vue principale du jeu de manipulation de lettres
struct GameView: View {
    // Observation de l'état du jeu
    @ObservedObject var gameState: GameState
    
    // États locaux pour la gestion des interactions
    @State private var currentDragIndex: Int? = nil // Index de la lettre actuellement déplacée
    @State private var letterOffset: CGSize = .zero // Décalage de la lettre pendant le glissement
    @State private var draggedLetter: Character? = nil // Lettre actuellement déplacée
    @State private var bottomLetters: [Character?] = [] // Lettres placées dans la zone du bas
    @State private var isDropTargeted: [Bool] = [] // Suivi des zones de dépôt ciblées
    @State private var dragStartLocation: CGPoint = .zero // Point de départ du glissement
    @State private var dropAreaFrames: [CGRect] = [] // Cadres des zones de dépôt
    @State private var isWordValid: Bool = false // Validation du mot
    @State private var isCorrectWord: Bool = false // Vérification si le mot est correct
    @State private var showWinAlert: Bool = false // Affichage de l'alerte de victoire
    
    // Environnement pour fermer la vue
    @Environment(\.dismiss) private var dismiss
    
    // Configuration de la grille adaptative
    let columns = [GridItem(.adaptive(minimum: 50))]
    
    // Initialisateur de la vue
    init(gameState: GameState) {
        self.gameState = gameState
        // Affiche le mot courant dans la console
        print(gameState.currentWord?.word)
    }
    
    // Corps principal de la vue
    var body: some View {
        NavigationStack {
            VStack {
                // Titre du jeu
                Text("Charivari des mots")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Grille des lettres mélangées en haut de l'écran
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(gameState.letters.indices, id: \.self) { index in
                        if let letter = gameState.letters[safe: index] {
                            // Affichage de chaque lettre
                            Text(String(letter).lowercased())
                                .font(.title)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                            // Geste de tap pour placer la lettre
                                .gesture(
                                    TapGesture()
                                        .onEnded {
                                            // Trouve le premier emplacement vide et place la lettre
                                            if let firstEmptyIndex = bottomLetters.firstIndex(where: { $0 == nil }) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    bottomLetters[firstEmptyIndex] = letter
                                                    gameState.letters.remove(at: index)
                                                    checkSolution()
                                                }
                                            }
                                        }
                                )
                            // Geste de glissement pour déplacer la lettre
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                    // Gestion du mouvement de glissement
                                        .onChanged { value in
                                            // Initialise le glissement si pas déjà en cours
                                            if currentDragIndex == nil {
                                                currentDragIndex = index
                                                draggedLetter = letter
                                                dragStartLocation = value.startLocation
                                            }
                                            
                                            // Calcul du décalage de la lettre
                                            letterOffset = CGSize(
                                                width: value.location.x - dragStartLocation.x,
                                                height: value.location.y - dragStartLocation.y
                                            )
                                            
                                            // Gestion du survol des zones de dépôt
                                            let location = value.location
                                            for (idx, _) in bottomLetters.enumerated() {
                                                if isLocationWithinDropArea(location, boxIndex: idx) {
                                                    if !isDropTargeted[idx] {
                                                        withAnimation(.easeInOut(duration: 0.1)) {
                                                            isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                                                            isDropTargeted[idx] = true
                                                        }
                                                    }
                                                    break
                                                } else {
                                                    withAnimation(.easeInOut(duration: 0.1)) {
                                                        isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                                                    }
                                                }
                                            }
                                        }
                                    // Gestion de la fin du glissement
                                        .onEnded { value in
                                            let location = value.location
                                            var didDrop = false
                                            
                                            // Vérifie si la lettre a été déposée dans une zone valide
                                            for (idx, isTargeted) in isDropTargeted.enumerated() {
                                                if isTargeted && bottomLetters[idx] == nil {
                                                    if let draggedLetter = draggedLetter,
                                                       let sourceIndex = currentDragIndex {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            bottomLetters[idx] = draggedLetter
                                                            gameState.letters.remove(at: sourceIndex)
                                                        }
                                                        didDrop = true
                                                        checkSolution()
                                                    }
                                                    break
                                                }
                                            }
                                            
                                            // Gestion si la lettre n'a pas été déposée
                                            if !didDrop {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    letterOffset = .zero
                                                }
                                            }
                                            
                                            // Réinitialisation des états de glissement
                                            withAnimation(.easeOut(duration: 0.2)) {
                                                isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                                            }
                                            
                                            currentDragIndex = nil
                                            draggedLetter = nil
                                        }
                                )
                            // Application de l'offset et de la profondeur lors du glissement
                                .offset(currentDragIndex == index ? letterOffset : .zero)
                                .zIndex(currentDragIndex == index ? 1 : 0)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // Zone de dépôt pour construire le mot (affichée uniquement quand un mot est disponible)
                if let currentWord = gameState.currentWord?.word, currentWord.count > 0 {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(0..<bottomLetters.count, id: \.self) { index in
                                ZStack {
                                    // Cadre de la zone de dépôt
                                    Rectangle()
                                        .strokeBorder(isDropTargeted[index] ? Color.green : Color.blue, lineWidth: isDropTargeted[index] ? 3 : 2)
                                        .background(Color.gray.opacity(0.2))
                                        .frame(height: 50)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .background(GeometryReader { geometry in
                                            Color.clear.onAppear {
                                                // Mémorisation du cadre de la zone de dépôt
                                                if index >= 0 && index < dropAreaFrames.count {
                                                    dropAreaFrames[index] = geometry.frame(in: .global)
                                                } else {
                                                    print("Index \(index) est hors limites!")
                                                }
                                            }
                                        })
                                    // Geste de tap pour retirer une lettre
                                        .gesture(
                                            TapGesture()
                                                .onEnded {
                                                    if let letter = bottomLetters[index] {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            gameState.letters.append(letter)
                                                            bottomLetters[index] = nil
                                                        }
                                                    }
                                                }
                                        )
                                    // Geste de glissement pour déplacer une lettre de la zone du bas
                                        .gesture(
                                            DragGesture(coordinateSpace: .global)
                                                .onChanged { value in
                                                    if let letter = bottomLetters[index] {
                                                        draggedLetter = letter
                                                        dragStartLocation = value.startLocation
                                                        letterOffset = CGSize(
                                                            width: value.location.x - dragStartLocation.x,
                                                            height: value.location.y - dragStartLocation.y
                                                        )
                                                    }
                                                }
                                                .onEnded { value in
                                                    let location = value.location
                                                    var didMove = false
                                                    
                                                    // Vérifie si la lettre peut être replacée dans la zone du haut
                                                    for (topIndex, _) in gameState.letters.enumerated() {
                                                        if isLocationWithinTopRow(location, boxIndex: topIndex) {
                                                            if let draggedLetter = draggedLetter,
                                                               bottomLetters[index] != nil {
                                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                                    gameState.letters.insert(draggedLetter, at: topIndex)
                                                                    bottomLetters[index] = nil
                                                                }
                                                                didMove = true
                                                            }
                                                            break
                                                        }
                                                    }
                                                    
                                                    // Gestion si la lettre n'a pas été déplacée
                                                    if !didMove {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            letterOffset = .zero
                                                        }
                                                    }
                                                    
                                                    letterOffset = .zero
                                                    draggedLetter = nil
                                                }
                                        )
                                    
                                    // Affichage de la lettre dans la zone de dépôt
                                    if let letter = bottomLetters[index] {
                                        Text(String(letter))
                                            .font(.title)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                // Affichage du temps écoulé
                Text("Time: \(Int(gameState.elapsedTime)) seconds")
                    .font(.headline)
                    .padding()
                
                // Affichage du score
                Text("Score: \(gameState.score)")
                    .font(.title2)
                    .padding()
                
                // Bouton pour abandonner
                Button(action: {
                    // Arrête le chronomètre
                    gameState.stopTimer()
                    
                    // Affiche l'alerte de fin de partie
                    showWinAlert = true
                    isCorrectWord = false
                }) {
                    Text("Donner sa langue au chat")
                        .font(.title2)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            // Actions à l'apparition de la vue
            .onAppear {
                // Charge l'état du jeu sauvegardé si disponible
                gameState.loadGameState()
                
                // Récupère un nouveau mot si aucun mot n'est présent
                if gameState.currentWord?.word == nil {
                    Task {
                        await gameState.fetchNewWord()
                    }
                }
                
                // Initialise la zone de dépôt des lettres
                if let currentWord = gameState.currentWord?.word {
                    bottomLetters = Array(repeating: nil, count: currentWord.count)
                    isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                    dropAreaFrames = Array(repeating: .zero, count: bottomLetters.count)
                }
            }
            // Réagit aux changements de mot
            .onChange(of: gameState.currentWord) { newWord in
                if let currentWord = newWord?.word, currentWord.count > 0 {
                    isWordValid = true
                    bottomLetters = Array(repeating: nil, count: currentWord.count)
                    isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                    dropAreaFrames = Array(repeating: .zero, count: bottomLetters.count)
                } else {
                    isWordValid = false
                }
            }
            // Gestion des alertes de fin de partie
            .alert(isPresented: $showWinAlert) {
                if isCorrectWord {
                    // Alerte en cas de victoire
                    return Alert(
                        title: Text("Bravo, vous avez trouvé le mot!"),
                        message: Text("Votre score est \(gameState.score)"),
                        primaryButton: .default(Text("Jouer une nouvelle partie")) {
                            resetGame()
                        },
                        secondaryButton: .cancel(Text("Retour au menu")) {
                            resetGame()
                            dismiss()
                        }
                    )
                } else {
                    // Alerte en cas d'échec
                    return Alert(
                        title: Text("Meilleure chance la prochaine fois!"),
                        message: Text("Le mot était: \(gameState.currentWord?.word ?? "")"),
                        primaryButton: .default(Text("Jouer une nouvelle partie")) {
                            resetGame()
                        },
                        secondaryButton: .cancel(Text("Retour au menu")) {
                            resetGame()
                            dismiss()
                        }
                    )
                }
            }
            // Sauvegarde de l'état du jeu à la disparition de la vue
            .onDisappear {
                gameState.saveGameState()
            }
        }
    }
    
    // Vérifie si un point se trouve dans une zone de dépôt
    private func isLocationWithinDropArea(_ location: CGPoint, boxIndex: Int) -> Bool {
        let dropAreaFrame = dropAreaFrames[boxIndex]
        return dropAreaFrame.contains(location)
    }
    
    // Vérifie si un point se trouve dans la ligne supérieure
    private func isLocationWithinTopRow(_ location: CGPoint, boxIndex: Int) -> Bool {
        let boxWidth: CGFloat = 70  // Largeur d'une case
        let boxHeight: CGFloat = 50  // Hauteur d'une case
        let boxSpacing: CGFloat = 10  // Espacement entre les cases
        let startX: CGFloat = 50 + (boxWidth + boxSpacing) * CGFloat(boxIndex)  // Position X de la première case en fonction de l'index
        
        let dropAreaY: CGFloat = 100  // Position Y du début de la zone de dépôt
        let dropAreaBottomY = dropAreaY + boxHeight  // Position Y de la fin de la zone de dépôt
        
        // Vérifie si les coordonnées du point sont dans la zone de la ligne supérieure
        return location.x >= startX && location.x <= startX + boxWidth &&
        location.y >= dropAreaY && location.y <= dropAreaBottomY
    }
    
    // Vérifie si la solution est correcte
    private func checkSolution() {
        let solution = bottomLetters.compactMap { $0 }  // Récupère les lettres de la solution
        let solutionWord = String(solution).lowercased()  // Crée un mot avec les lettres en minuscule
        
        // Vérifie si le mot de la solution correspond au mot actuel
        if let currentWord = gameState.currentWord?.word {
            if solutionWord.lowercased() == currentWord.lowercased() {  // Compare le mot de la solution avec le mot actuel
                isCorrectWord = true  // Marque le mot comme correct
                showWinAlert = true  // Affiche l'alerte de victoire
                submitScore()  // Soumet le score
                gameState.stopTimer()  // Arrête le chronomètre
            } else {
                isCorrectWord = false  // Marque le mot comme incorrect
            }
        }
    }
    
    // Soumet le score à un service externe
    private func submitScore() {
        // Vérifie si le mot actuel existe
        if let currentWord = gameState.currentWord?.word {
            // Sauvegarde le mot résolu localement
            SolvedWordsManager.shared.saveSolvedWord(
                word: currentWord,  // Mot actuel
                secret: gameState.currentWord?.secret ?? "",  // Secret du mot actuel
                time: Int(gameState.elapsedTime),  // Temps écoulé
                score: gameState.score  // Score du joueur
            )
            
            Task {
                do {
                    // S'assure que `currentWord` est déballé avant de procéder
                    guard let currentWord = gameState.currentWord else {
                        print("Aucun mot actuel disponible")  // Si aucun mot n'est disponible, affiche un message d'erreur
                        return
                    }
                    
                    // Formatte le mot pour qu'il commence par une majuscule et le reste en minuscule
                    let formattedWord = currentWord.word
                    let formattedWordWithCapital = formattedWord.prefix(1).uppercased() + formattedWord.dropFirst().lowercased()
                    
                    // Envoie le score au serveur
                    try await NetworkService.submitScore(
                        word: formattedWord,  // Mot formaté
                        secret: gameState.currentWord?.secret ?? "",  // Secret du mot actuel
                        name: "Cedrik",  // Nom du joueur
                        score: gameState.score  // Score du joueur
                    )
                } catch {
                    print("Échec de la soumission du score : \(error)")  // En cas d'erreur, affiche un message d'erreur
                }
            }
        }
    }
    
    // Réinitialise l'état du jeu
    private func resetGame() {
        // Efface les données sauvegardées dans UserDefaults
        UserDefaults.standard.removeObject(forKey: "gameStateKey")
        
        // Réinitialise l'état du jeu
        gameState.reset()
        Task {
            await gameState.fetchNewWord()  // Récupère un nouveau mot pour commencer une nouvelle partie
        }
    }
}
