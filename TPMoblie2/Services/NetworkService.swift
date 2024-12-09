//
//  NetworkService.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
/// Services/NetworkService.swift
import Foundation

// La classe NetworkService gère toutes les interactions avec le réseau (API).
class NetworkService {
    
    // L'URL de base pour toutes les requêtes API
    static let baseURL = "https://420c56.drynish.synology.me"
    
    // Fonction pour récupérer un nouveau mot depuis le serveur
    static func getNewWord() async throws -> Word {
        // Construction de l'URL pour la requête API
        guard let url = URL(string: "\(baseURL)/new") else {
            throw NetworkError.invalidURL  // Si l'URL est invalide, lancer une erreur
        }
        
        // Attendre la réponse de la requête réseau
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Vérifier que la réponse est valide (code HTTP 200)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse  // Si la réponse n'est pas correcte, lancer une erreur
        }
        
        // Décoder les données reçues en un objet de type Word
        return try JSONDecoder().decode(Word.self, from: data)
    }
    
    // Fonction pour soumettre un score pour un mot donné
    static func submitScore(word: String, secret: String, name: String, score: Int) async throws {
        // Encoder les mots et le secret pour s'assurer qu'ils sont valides dans l'URL
        guard let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let encodedSecret = secret.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw NetworkError.invalidURL  // Si l'encodage échoue, lancer une erreur
        }
        
        // Créer l'URL pour soumettre le score en incluant les mots, le secret, le nom du joueur et le score
        let urlString = "\(baseURL)/solve/\(encodedWord)/\(encodedSecret)/\(name)/\(score)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL  // Si l'URL construite est invalide, lancer une erreur
        }

        // Préparer la requête HTTP
        var request = URLRequest(url: url)
        request.httpMethod = "POST"  // Spécifier que la méthode HTTP est POST
        
        // Log pour le débogage : afficher les informations de la requête
        print("Submitting score:")
        print("URL: \(urlString)")
        print("HTTP Method: \(request.httpMethod ?? "Unknown")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Effectuer la requête POST de manière asynchrone
        let (_, response) = try await URLSession.shared.data(for: request)

        // Afficher le code de statut de la réponse pour le débogage
        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
        } else {
            print("Invalid response received!")  // Si la réponse est invalide, afficher un message d'erreur
        }
        
        // Vérifier que la réponse a un statut HTTP 200 (OK)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse  // Si la réponse n'est pas correcte, lancer une erreur
        }

        // Afficher un message de succès pour la soumission du score
        print("Score submitted successfully!")
    }
    
    // Fonction pour récupérer les scores d'un mot spécifique
    static func getScores(for word: String) async throws -> ScoreList {
        // Construire l'URL pour récupérer les scores du mot donné
        guard let url = URL(string: "\(baseURL)/score/\(word)") else {
            throw NetworkError.invalidURL  // Si l'URL est invalide, lancer une erreur
        }
        
        // Attendre la réponse de la requête réseau
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Log pour le débogage : afficher la réponse brute (JSON) reçue
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw Response: \(jsonString)")  // Affiche la chaîne JSON brute pour le débogage
        }
        
        // Vérifier que la réponse est valide (code HTTP 200)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse  // Si la réponse n'est pas correcte, lancer une erreur
        }
        
        // Décoder les données reçues en un objet de type ScoreList
        return try JSONDecoder().decode(ScoreList.self, from: data)
    }
}
