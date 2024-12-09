import SwiftUI
import CoreMotion

struct AnimatedBackgroundView: View {
    @State private var letterPositions: [CGPoint] = []
    @State private var letterVelocities: [CGVector] = [] // To track velocities for gravity and collision
    @State private var letterScales: [CGFloat] = [] // To control the size of the letters
    @State private var letterColors: [Color] = [] // Store dynamic colors for each letter
    @State private var isAnimating: Bool = false // To control the start of animation
    @State private var accelerometerData: CMAccelerometerData? = nil // Store accelerometer data
    
    private let motionManager = CMMotionManager() // Motion manager to access accelerometer data
    
    // The phrase we are animating
    let phrase = "Charivari"
    
    // Gravity and physics constants
    let gravity: CGFloat = 0.3 // Gravity strength
    let bounceFactor: CGFloat = 0.6 // Bounce effect on collision
    
    // Screen boundaries
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let screenHeight: CGFloat = UIScreen.main.bounds.height
    let bottomY: CGFloat // Position where letters stop falling (bottom of the screen)
    
    init() {
        self.bottomY = screenHeight - 100 // Adjust the "bottom" position
    }
    
    var body: some View {
        ZStack {
            // Soft Gradient Rainbow Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red,
                    Color.orange,
                    Color.yellow,
                    Color.green,
                    Color.blue,
                    Color.purple
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Animated Letters
            ForEach(0..<phrase.count, id: \.self) { charIndex in
                Text(String(phrase[phrase.index(phrase.startIndex, offsetBy: charIndex)]))
                    .font(.system(size: 60)) // Set font size
                    .foregroundColor(letterColors[safe: charIndex] ?? .black) // Use dynamic color
                    .opacity(1.0) // Fully visible
                    .position(letterPositions[safe: charIndex] ?? .zero) // Position
                    .scaleEffect(letterScales[safe: charIndex] ?? 1.0) // Scaling effect
                    .onAppear {
                        if !isAnimating {
                            startAnimation() // Start the animation for the whole sequence
                        }
                    }
            }
        }
        .onAppear {
            initializeLetterPositions() // Initialize starting positions of letters
            startGravityAnimation() // Start gravity animation
            startColorTransition() // Start the color transition
            startMotionUpdates() // Start receiving accelerometer data
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates() // Stop accelerometer updates when the view disappears
        }
    }
    
    // Function to get a random color for the letters
    func getRandomColor() -> Color {
        return Color(hue: Double.random(in: 0...1), saturation: 0.8, brightness: 0.9)
    }
    
    // Function to initialize letter positions
    private func initializeLetterPositions() {
        // Initialize starting positions for each letter
        let numberOfLetters = phrase.count
        let letterSpacing: CGFloat = 50 // Space between letters
        
        // Position the letters across the screen and start them off smaller
        letterPositions = (0..<numberOfLetters).map { index in
            let xPos = CGFloat(index) * letterSpacing + 50 // Space letters horizontally
            let yPos: CGFloat = -60 // Start just off the top of the screen
            return CGPoint(x: xPos, y: yPos)
        }
        
        // Set initial velocities for all letters (falling speed)
        letterVelocities = Array(repeating: CGVector(dx: 0, dy: 2), count: numberOfLetters) // Initial downward velocity
        
        // Set initial scaling for letters (smaller at start)
        letterScales = Array(repeating: 0.6, count: numberOfLetters) // Smaller size at start
        
        // Set initial colors for the letters
        letterColors = Array(repeating: getRandomColor(), count: numberOfLetters) // Random colors
    }
    
    // Start gravity simulation and device motion detection
    private func startGravityAnimation() {
        // Start a timer for continuous updates
        Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { _ in
            // Apply gravity and update letter positions
            for i in 0..<phrase.count {
                // Apply gravity force (downwards) to velocity
                letterVelocities[i].dy += gravity // Simulate downward gravity
                
                // Update letter positions based on velocities
                letterPositions[i].x += letterVelocities[i].dx
                letterPositions[i].y += letterVelocities[i].dy
                
                // Collision detection for walls (left, right, bottom)
                if letterPositions[i].x < 0 {
                    letterPositions[i].x = 0
                    letterVelocities[i].dx *= -bounceFactor // Bounce back horizontally
                } else if letterPositions[i].x > screenWidth {
                    letterPositions[i].x = screenWidth
                    letterVelocities[i].dx *= -bounceFactor // Bounce back horizontally
                }
                
                if letterPositions[i].y > bottomY {
                    letterPositions[i].y = bottomY
                    letterVelocities[i].dy *= -bounceFactor // Bounce back vertically
                }
                
                // Scale down the letters based on their distance from the center
                let distanceToCenter = distance(from: letterPositions[i], to: CGPoint(x: screenWidth / 2, y: screenHeight / 2))
                letterScales[i] = max(0.5, 1 - distanceToCenter / 500) // Reduce size as they move away from the center
            }
        }
    }
    
    // Start the smooth color transition for the letters
    private func startColorTransition() {
        // Timer to gradually change colors every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            // Gradually change the colors of the letters
            for i in 0..<letterColors.count {
                withAnimation(.easeInOut(duration: 3)) {
                    letterColors[i] = getRandomColor() // Assign new random color with smooth transition
                }
            }
        }
    }
    
    // Start receiving accelerometer data to move letters
    private func startMotionUpdates() {
        motionManager.accelerometerUpdateInterval = 1/60 // Update interval (60 updates per second)
        
        motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
            if let data = data {
                // Map accelerometer data to letter movement
                let xAcceleration = CGFloat(data.acceleration.x) // Horizontal tilt (left-right)
                let yAcceleration = CGFloat(data.acceleration.y) // Vertical tilt (up-down)
                
                // Apply the accelerometer data to move the letters
                for i in 0..<phrase.count {
                    letterVelocities[i].dx = xAcceleration * 100 // Adjust multiplier for sensitivity
                    letterVelocities[i].dy = yAcceleration * 100 // Adjust multiplier for sensitivity
                }
            }
        }
    }
    
    // Calculate distance from a point to another
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    // Function to start the animation for the whole sequence
    private func startAnimation() {
        isAnimating = true // Set animation flag to true
    }
}
