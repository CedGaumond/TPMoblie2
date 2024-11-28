import SwiftUI

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct GameView: View {
    @ObservedObject var gameState: GameState
    @State private var currentDragIndex: Int? = nil
    @State private var letterOffset: CGSize = .zero
    @State private var draggedLetter: Character? = nil
    @State private var bottomLetters: [Character?] = []
    @State private var isDropTargeted: [Bool] = []
    @State private var dragStartLocation: CGPoint = .zero
    @State private var dropAreaFrames: [CGRect] = []
    @State private var isWordValid: Bool = false
    @State private var isCorrectWord: Bool = false  // Track if the word is correct
    @State private var showWinAlert: Bool = false  // Track if the win alert should be shown

    @Environment(\.dismiss) private var dismiss  // Used for "popping back" to the previous screen

    let columns = [GridItem(.adaptive(minimum: 50))]

    init(gameState: GameState) {
        self.gameState = gameState
    }

    var body: some View {
        NavigationStack {
            VStack {
                Text("Charivari des mots")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                // Scrambled letters at the top
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(gameState.letters.indices, id: \.self) { index in
                        if let letter = gameState.letters[safe: index] {
                            Text(String(letter))
                                .font(.title)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                                .gesture(
                                    TapGesture()
                                        .onEnded {
                                            if let firstEmptyIndex = bottomLetters.firstIndex(where: { $0 == nil }) {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    bottomLetters[firstEmptyIndex] = letter
                                                    gameState.letters.remove(at: index)
                                                    checkSolution()  // Check solution after every tap
                                                }
                                            }
                                        }
                                )
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged { value in
                                            if currentDragIndex == nil {
                                                currentDragIndex = index
                                                draggedLetter = letter
                                                dragStartLocation = value.startLocation
                                            }

                                            letterOffset = CGSize(
                                                width: value.location.x - dragStartLocation.x,
                                                height: value.location.y - dragStartLocation.y
                                            )

                                            // Highlight drop areas based on location
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
                                        .onEnded { value in
                                            let location = value.location
                                            var didDrop = false

                                            for (idx, isTargeted) in isDropTargeted.enumerated() {
                                                if isTargeted && bottomLetters[idx] == nil {
                                                    if let draggedLetter = draggedLetter,
                                                       let sourceIndex = currentDragIndex {
                                                        // Successfully drop the letter in the target box
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            bottomLetters[idx] = draggedLetter  // Add to bottom box
                                                            gameState.letters.remove(at: sourceIndex)  // Remove from top row
                                                        }
                                                        didDrop = true
                                                        checkSolution()  // Check solution after every drop
                                                    }
                                                    break
                                                }
                                            }
                                            if !didDrop {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    letterOffset = .zero
                                                }
                                            }

                                            withAnimation(.easeOut(duration: 0.2)) {
                                                isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                                            }
                                            currentDragIndex = nil
                                            draggedLetter = nil
                                        }
                                )
                                .offset(currentDragIndex == index ? letterOffset : .zero)
                                .zIndex(currentDragIndex == index ? 1 : 0)
                        }
                    }
                }
                .padding()

                Spacer()

                // Only show the bottom boxes if the word is valid
                if isWordValid, let currentWord = gameState.currentWord {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(0..<bottomLetters.count, id: \.self) { index in
                                ZStack {
                                    Rectangle()
                                        .strokeBorder(isDropTargeted[index] ? Color.green : Color.blue,
                                                      lineWidth: isDropTargeted[index] ? 3 : 2)
                                        .background(Color.gray.opacity(0.2))
                                        .frame(height: 50)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                        .background(GeometryReader { geometry in
                                            Color.clear.onAppear {
                                                // Capture the frame of the drop area
                                                dropAreaFrames[index] = geometry.frame(in: .global)
                                            }
                                        })
                                        .gesture(
                                            TapGesture()
                                                .onEnded {
                                                    if let letter = bottomLetters[index] {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            gameState.letters.append(letter)  // Add back to top row
                                                            bottomLetters[index] = nil  // Remove from bottom row
                                                        }
                                                    }
                                                }
                                        )
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

                                                    // Check if it's dragged back to the top row
                                                    for (topIndex, _) in gameState.letters.enumerated() {
                                                        if isLocationWithinTopRow(location, boxIndex: topIndex) {
                                                            if let draggedLetter = draggedLetter,
                                                               bottomLetters[index] != nil {
                                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                                    gameState.letters.insert(draggedLetter, at: topIndex) // Insert back to top row
                                                                    bottomLetters[index] = nil  // Remove from bottom row
                                                                }
                                                                didMove = true
                                                            }
                                                            break
                                                        }
                                                    }

                                                    // If no valid move, animate back to bottom row
                                                    if !didMove {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                            letterOffset = .zero
                                                        }
                                                    }

                                                    letterOffset = .zero
                                                    draggedLetter = nil
                                                }
                                        )

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

                Text("Time: \(Int(gameState.elapsedTime)) seconds")
                    .font(.headline)
                    .padding()

            }
            .onAppear {
                Task {
                    await gameState.fetchNewWord()
                }
            }
            .onChange(of: gameState.currentWord) { newWord in
                if let currentWord = newWord, currentWord.word.count > 0 {
                    isWordValid = true
                    bottomLetters = Array(repeating: nil, count: currentWord.word.count)
                    isDropTargeted = Array(repeating: false, count: bottomLetters.count)
                    dropAreaFrames = Array(repeating: .zero, count: bottomLetters.count)
                } else {
                    isWordValid = false
                }
            }
            .alert(isPresented: $showWinAlert) {
                Alert(
                    title: Text("Bravo, vous avez trouvé le mot!"),
                    message: Text("Vous avez terminé le jeu."),
                    primaryButton: .default(Text("Jouer une nouvelle partie")) {
                        resetGame()  // Call your reset game function
                    },
                    secondaryButton: .cancel(Text("Retour au menu")) {
                        dismiss()  // Pop back to the previous view (menu)
                    }
                )
            }
        }
    }

    private func isLocationWithinDropArea(_ location: CGPoint, boxIndex: Int) -> Bool {
        let dropAreaFrame = dropAreaFrames[boxIndex]
        return dropAreaFrame.contains(location)
    }

    private func isLocationWithinTopRow(_ location: CGPoint, boxIndex: Int) -> Bool {
        let boxWidth: CGFloat = 70
        let boxHeight: CGFloat = 50
        let boxSpacing: CGFloat = 10
        let startX: CGFloat = 50 + (boxWidth + boxSpacing) * CGFloat(boxIndex)

        let dropAreaY: CGFloat = 100
        let dropAreaBottomY = dropAreaY + boxHeight

        return location.x >= startX && location.x <= startX + boxWidth &&
               location.y >= dropAreaY && location.y <= dropAreaBottomY
    }

    private func checkSolution() {
        let solution = bottomLetters.compactMap { $0 }
        let solutionWord = String(solution)
        
        // Check if the word is correct
        isCorrectWord = solutionWord == gameState.currentWord?.word
        
        if isCorrectWord {
            // Stop the timer when the player wins
            gameState.stopTimer()

            // Save the solved word to UserDefaults
            if let currentWord = gameState.currentWord {
                let timeTaken = Int(gameState.elapsedTime)

                // Create a Word object using the solutionWord and currentWord.secret
                let solvedWord = Word(word: solutionWord, secret: currentWord.word)

                // Save the solved word with its time
                SolvedWordsManager.shared.saveSolvedWord(
                    word: solvedWord,  // Pass the Word object
                    time: timeTaken    // Pass the time taken
                )
            }
            
            // Show the win alert
            showWinAlert = true
        }
    }


    private func resetGame() {
        gameState.reset()  // Assuming `reset()` is a method in `GameState`
        showWinAlert = false  // Hide the alert
        Task {
            await gameState.fetchNewWord()  // Fetch a new word after resetting
        }
    }
}
