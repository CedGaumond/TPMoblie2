//
//  DataBaseManager.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//

// Importation des modules nécessaires
import Foundation
import SQLite3

// Définition de la classe DatabaseManager qui gère la base de données SQLite
class DatabaseManager {
    
    // Singleton pour garantir une seule instance de DatabaseManager
    static let shared = DatabaseManager()
    
    // Pointeur opaque pour la base de données SQLite
    private var db: OpaquePointer?
    
    // Initialisateur privé pour empêcher la création d'instances multiples
    private init() {
        setupDatabase()  // Appelle la méthode pour configurer la base de données
    }
    
    // Méthode pour configurer et ouvrir la base de données SQLite
    private func setupDatabase() {
        // Crée l'URL du fichier de la base de données dans le répertoire des documents
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("charivari.sqlite")
        
        // Ouvre la base de données SQLite. Si l'ouverture échoue, affiche une erreur
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }

        // Requête SQL pour créer la table 'cached_words' si elle n'existe pas déjà
        let createWordTable = """
            CREATE TABLE IF NOT EXISTS cached_words (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                word TEXT NOT NULL,
                secret TEXT NOT NULL
            );
        """

        // Requête SQL pour créer la table 'solved_words' si elle n'existe pas déjà
        let createSolvedTable = """
            CREATE TABLE IF NOT EXISTS solved_words (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                word TEXT NOT NULL,
                secret TEXT NOT NULL,
                player TEXT NOT NULL,
                score INTEGER NOT NULL,
                uploaded INTEGER DEFAULT 0
            );
        """

        // Exécute la requête SQL pour créer la table 'cached_words'
        if sqlite3_exec(db, createWordTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating cached_words table")
        }

        // Exécute la requête SQL pour créer la table 'solved_words'
        if sqlite3_exec(db, createSolvedTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating solved_words table")
        }
    }

    // Méthode pour enregistrer un mot dans la table 'cached_words'
    func cacheWord(_ word: Word) {
        // Requête SQL pour insérer un mot et sa version secrète dans la table 'cached_words'
        let insertSQL = "INSERT INTO cached_words (word, secret) VALUES (?, ?);"
        var statement: OpaquePointer?

        // Prépare la requête SQL
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            // Lier le mot à la première position
            sqlite3_bind_text(statement, 1, (word.word as NSString).utf8String, -1, nil)
            // Lier la version secrète du mot à la deuxième position
            sqlite3_bind_text(statement, 2, (word.secret as NSString).utf8String, -1, nil)

            // Exécute la requête et vérifie si l'insertion a échoué
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting word")
            }
        }

        // Finalise l'instruction SQL
        sqlite3_finalize(statement)
    }

    // Méthode pour enregistrer un mot résolu dans la table 'solved_words'
    func saveSolvedWord(word: String, secret: String, player: String, score: Int) {
        // Requête SQL pour insérer un mot résolu dans la table 'solved_words'
        let insertSQL = """
            INSERT INTO solved_words (word, secret, player, score)
            VALUES (?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        // Prépare la requête SQL
        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            // Lier le mot à la première position
            sqlite3_bind_text(statement, 1, (word as NSString).utf8String, -1, nil)
            // Lier la version secrète du mot à la deuxième position
            sqlite3_bind_text(statement, 2, (secret as NSString).utf8String, -1, nil)
            // Lier le nom du joueur à la troisième position
            sqlite3_bind_text(statement, 3, (player as NSString).utf8String, -1, nil)
            // Lier le score à la quatrième position
            sqlite3_bind_int(statement, 4, Int32(score))

            // Exécute la requête et vérifie si l'insertion a échoué
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving solved word")
            }
        }

        // Finalise l'instruction SQL
        sqlite3_finalize(statement)
    }
}
