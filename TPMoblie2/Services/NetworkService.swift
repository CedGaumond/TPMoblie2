//
//  NetworkService.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
/// Services/NetworkService.swift
import Foundation

// Now NetworkError will be accessible here
class NetworkService {
    static let baseURL = "https://420c56.drynish.synology.me"
    
    static func getNewWord() async throws -> Word {
        guard let url = URL(string: "\(baseURL)/new") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(Word.self, from: data)
    }
    
    static func submitScore(word: String, secret: String, name: String, score: Int) async throws {
        let urlString = "\(baseURL)/solve/\(word)/\(secret)/\(name)/\(score)"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
    }
    
    static func getScores(for word: String) async throws -> ScoreList {
        guard let url = URL(string: "\(baseURL)/score/\(word)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(ScoreList.self, from: data)
    }
}
