import Foundation

// Déclaration de la classe `GameState`, conforme au protocole `ObservableObject`
// Cela permet à SwiftUI d'observer et de réagir aux changements de l'état du jeu
class GameState: ObservableObject {
    
    // Propriétés observées, qui vont déclencher une mise à jour de l'interface utilisateur lorsque leurs valeurs changent
    
    @Published var currentWord: Word?  // Le mot actuel à deviner (de type Word)
    @Published var letters: [Character] = []  // Liste des lettres du mot mélangé (initialisée comme vide)
    @Published var elapsedTime: TimeInterval = 0  // Temps écoulé depuis le début du jeu (initialisé à 0)
    @Published var isPlaying = false  // Indicateur pour savoir si le jeu est en cours
    @Published var score: Int = 30  // Le score commence à 30 (score maximum possible)
    private var timer: Timer?  // Minuterie pour suivre le temps écoulé
    
    // Fonction pour vérifier si une partie est sauvegardée dans UserDefaults
    func isGameSaved() -> Bool {
        return UserDefaults.standard.object(forKey: "currentWord") != nil &&  // Vérifier si le mot actuel est sauvegardé
               UserDefaults.standard.object(forKey: "letters") != nil  // Vérifier si les lettres sont sauvegardées
    }
    
    // Fonction pour réinitialiser les données sauvegardées dans UserDefaults
    func resetUserDefault() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "currentWord")  // Supprimer le mot actuel sauvegardé
        defaults.removeObject(forKey: "letters")  // Supprimer les lettres sauvegardées
        defaults.removeObject(forKey: "elapsedTime")  // Supprimer le temps écoulé sauvegardé
        defaults.removeObject(forKey: "isPlaying")  // Supprimer l'état du jeu (en cours ou non)
        defaults.removeObject(forKey: "score")  // Supprimer le score sauvegardé
    }

    // Fonction pour sauvegarder l'état du jeu dans UserDefaults
    func saveGameState() {
        if let currentWord = self.currentWord {  // Vérifier si le mot actuel n'est pas nil
            UserDefaults.standard.set(currentWord.word, forKey: "currentWord")  // Sauvegarder le mot actuel
            UserDefaults.standard.set(self.letters.map { String($0) }.joined(), forKey: "letters")  // Sauvegarder les lettres sous forme de chaîne
            UserDefaults.standard.set(self.elapsedTime, forKey: "elapsedTime")  // Sauvegarder le temps écoulé
            UserDefaults.standard.set(self.score, forKey: "score")  // Sauvegarder le score
            UserDefaults.standard.set(self.isPlaying, forKey: "isPlaying")  // Sauvegarder l'état du jeu
            UserDefaults.standard.set(self.currentWord?.secret, forKey: "wordSecret")  // Sauvegarder le secret du mot
        }
    }

    // Fonction pour charger l'état du jeu depuis UserDefaults
    func loadGameState() {
        if let savedCurrentWord = UserDefaults.standard.string(forKey: "currentWord"),  // Charger le mot sauvegardé
           let savedLetters = UserDefaults.standard.string(forKey: "letters"),  // Charger les lettres sauvegardées
           let savedElapsedTime = UserDefaults.standard.value(forKey: "elapsedTime") as? TimeInterval,  // Charger le temps écoulé
           let savedIsPlaying = UserDefaults.standard.value(forKey: "isPlaying") as? Bool,  // Charger l'état du jeu
           let savedScore = UserDefaults.standard.value(forKey: "score") as? Int {  // Charger le score
           
           // Décoder les valeurs sauvegardées
           let wordSecret = UserDefaults.standard.string(forKey: "wordSecret") ?? ""  // Charger le secret du mot (si disponible)
           self.currentWord = Word(word: savedCurrentWord, secret: wordSecret)  // Créer un nouvel objet Word à partir des données sauvegardées
           self.letters = Array(savedLetters).compactMap { $0 }  // Convertir les lettres sauvegardées en tableau de caractères
           self.elapsedTime = savedElapsedTime  // Charger le temps écoulé
           self.isPlaying = savedIsPlaying  // Charger l'état du jeu
           self.score = savedScore  // Charger le score
       } else {
           print("Aucun état de jeu sauvegardé trouvé")  // Afficher un message si aucune sauvegarde n'est trouvée
       }
    }

    // Fonction pour démarrer une nouvelle partie avec un mot donné
    func startGame(word: Word) {
        currentWord = word  // Affecter le mot passé en paramètre à la variable currentWord
        letters = word.word.shuffled()  // Mélanger les lettres du mot pour augmenter la difficulté
        elapsedTime = 0  // Réinitialiser le temps écoulé à 0
        score = 30  // Réinitialiser le score à 30 (score maximum possible)
        isPlaying = true  // Indiquer que le jeu est en cours
        startTimer()  // Démarrer la minuterie pour suivre le temps
        saveGameState()  // Sauvegarder l'état du jeu
    }

    // Fonction pour récupérer un nouveau mot et démarrer une nouvelle partie avec ce mot
    func fetchNewWord() async {
        do {
            let word = try await NetworkService.getNewWord()  // Appeler un service réseau pour obtenir un nouveau mot
            DispatchQueue.main.async { [weak self] in  // Assurer que le code est exécuté sur le thread principal
                guard let self = self else { return }
                self.startGame(word: word)  // Démarrer le jeu avec le nouveau mot
            }
        } catch {
            print("Erreur lors de l'obtention du nouveau mot : \(error)")  // Afficher une erreur si la récupération du mot échoue
        }
    }

    // Fonction pour réinitialiser l'état du jeu
    func reset() {
        currentWord = nil  // Réinitialiser le mot actuel à nil
        letters = []  // Réinitialiser les lettres à un tableau vide
        elapsedTime = 0  // Réinitialiser le temps écoulé à 0
        score = 30  // Réinitialiser le score à 30
        isPlaying = false  // Indiquer que le jeu n'est plus en cours
        timer?.invalidate()  // Arrêter la minuterie (si elle existe)
        timer = nil  // Réinitialiser la minuterie à nil
        resetUserDefault()  // Effacer l'état sauvegardé du jeu
    }

    // Fonction pour démarrer la minuterie qui suit le temps écoulé
    func startTimer() {
        timer?.invalidate()  // Invalider toute minuterie existante avant de créer une nouvelle
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in  // Créer une nouvelle minuterie qui se répète toutes les secondes
            guard let self = self else { return }
            self.elapsedTime += 1  // Incrémenter le temps écoulé de 1 seconde
            self.updateScore()  // Mettre à jour le score en fonction du temps écoulé
            
            // Sauvegarder périodiquement toutes les 10 secondes pour éviter la perte de progression
            if Int(self.elapsedTime) % 10 == 0 {
                self.saveGameState()  // Sauvegarder l'état du jeu toutes les 10 secondes
            }
        }
    }

    // Fonction pour arrêter la minuterie
    func stopTimer() {
        timer?.invalidate()  // Invalider la minuterie
        timer = nil  // Réinitialiser la minuterie à nil
        isPlaying = false  // Indiquer que le jeu n'est plus en cours
        saveGameState()  // Sauvegarder l'état lorsque le jeu est arrêté
    }

    // Fonction pour mettre à jour le score en fonction du temps écoulé
    func updateScore() {
        // Déduire 1 point pour chaque seconde écoulée, mais ne pas descendre en dessous de 0
        if score > 0 {
            score = max(30 - Int(elapsedTime), 0)  // Le score est égal à 30 moins le temps écoulé, mais ne descend pas en dessous de 0
        }
    }
}
