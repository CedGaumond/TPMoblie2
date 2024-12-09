//
//  Word.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import Foundation

// La structure Word représente un mot à résoudre avec sa version secrète.
// Elle est conforme au protocole Codable pour l'encodage et le décodage en JSON,
// ainsi que Equatable et Hashable pour comparer et utiliser comme clé dans des dictionnaires ou des ensembles.
struct Word: Codable, Equatable, Hashable {
    
    // La propriété 'word' représente le mot à résoudre (ex. "apple").
    let word: String
    
    // La propriété 'secret' représente la version codée ou cryptée du mot (ex. "_ppl_").
    let secret: String

    // Enumération CodingKeys permet de mapper les noms des propriétés à ceux du JSON.
    enum CodingKeys: String, CodingKey {
        case word = "Word"    // Mapper la clé JSON 'Word' à la propriété 'word' dans la structure
        case secret = "Secret"  // Mapper la clé JSON 'Secret' à la propriété 'secret' dans la structure
    }
}

// La structure SolvedWord représente un mot résolu avec son temps et score.
// Elle est conforme au protocole Codable pour l'encodage et le décodage en JSON.
struct SolvedWord: Codable {
    
    // La propriété 'word' contient une instance de la structure 'Word'.
    let word: Word  // Stocke le mot complet (le mot et sa version secrète)
    
    // La propriété 'time' représente le temps écoulé pour résoudre le mot, en secondes.
    let time: Int
    
    // La propriété 'score' représente le score obtenu pour avoir résolu le mot.
    let score: Int  // Ajoute la propriété 'score'
}
