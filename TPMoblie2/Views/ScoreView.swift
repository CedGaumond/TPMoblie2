import SwiftUI

struct ScoresView: View {
    let word: String // This could be used to filter scores by word if necessary
    @State private var scores: [Score] = []
    
    var body: some View {
        List(scores, id: \.player) { score in
            HStack {
                Text(score.player)
                Spacer()
                Text("\(score.score) seconds")
            }
        }
        .onAppear {
            // Load scores when the view appears
            self.scores = ScoreManager.loadScoresFromUserDefaults()
        }
        .navigationTitle("Scores")
    }
}
