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

    let columns = [GridItem(.adaptive(minimum: 50))]

    init(gameState: GameState) {
        self.gameState = gameState
    }

    var body: some View {
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
                                // Tap gesture to place letter in the first available bottom slot
                                TapGesture()
                                    .onEnded {
                                        if let firstEmptyIndex = bottomLetters.firstIndex(where: { $0 == nil }) {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                bottomLetters[firstEmptyIndex] = letter
                                                gameState.letters.remove(at: index)
                                                print("Letter \(letter) placed in bottom slot \(firstEmptyIndex) by tap.")
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

                                        // Update the letter's offset based on drag
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
                                                    print("Letter \(draggedLetter) dropped into box \(idx).")
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
                                        // Add tap gesture to move letter back to top
                                        TapGesture()
                                            .onEnded {
                                                if let letter = bottomLetters[index] {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        gameState.letters.append(letter)  // Add back to top row
                                                        bottomLetters[index] = nil  // Remove from bottom row
                                                        print("Letter \(letter) moved back to top row by tap.")
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
                                                            print("Letter \(draggedLetter) moved back to top row by drag.")
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

            Button(action: {
                checkSolution()
            }) {
                Text("Submit")
                    .font(.headline)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
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
        let isCorrect = solutionWord == gameState.currentWord?.word
        print(isCorrect ? "Correct!" : "Incorrect. Try again.")
    }
}
