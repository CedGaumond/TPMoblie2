//
//  Score.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
// Définition des structures utilisées pour la gestion des scores

// Structure qui représente une liste de scores, conforme au protocole `Codable` pour la sérialisation JSON
struct ScoreList: Codable {
    
    // Définition des clés de codage pour mapper les noms JSON aux propriétés de la structure
    enum CodingKeys: String, CodingKey {
        case list = "List"  // Mapper le nom JSON 'List' à la propriété 'list' de la structure
        case error = "Error"  // Mapper le nom JSON 'Error' à la propriété 'error' de la structure
    }
    
    var list: [Score]  // Tableau contenant les scores (de type `Score`)
    var error: String  // Message d'erreur (si présent)
}

// Structure qui représente un score individuel, conforme également au protocole `Codable`
struct Score: Codable {
    
    // Définition des clés de codage pour mapper les noms JSON aux propriétés de la structure
    enum CodingKeys: String, CodingKey {
        case player = "Player"  // Mapper le nom JSON 'Player' à la propriété 'player' de la structure
        case score = "Score"    // Mapper le nom JSON 'Score' à la propriété 'score' de la structure
    }
    
    var player: String  // Nom du joueur
    var score: Int      // Score du joueur
}
