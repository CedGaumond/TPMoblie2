//
//  DataBaseManager.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//

// Persistence/DatabaseManager.swift
import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("charivari.sqlite")

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return
        }

        let createWordTable = """
            CREATE TABLE IF NOT EXISTS cached_words (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                word TEXT NOT NULL,
                secret TEXT NOT NULL
            );
        """

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

        if sqlite3_exec(db, createWordTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating cached_words table")
        }

        if sqlite3_exec(db, createSolvedTable, nil, nil, nil) != SQLITE_OK {
            print("Error creating solved_words table")
        }
    }

    func cacheWord(_ word: Word) {
        let insertSQL = "INSERT INTO cached_words (word, secret) VALUES (?, ?);"
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (word.word as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (word.secret as NSString).utf8String, -1, nil)

            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error inserting word")
            }
        }

        sqlite3_finalize(statement)
    }

    func saveSolvedWord(word: String, secret: String, player: String, score: Int) {
        let insertSQL = """
            INSERT INTO solved_words (word, secret, player, score)
            VALUES (?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        if sqlite3_prepare_v2(db, insertSQL, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, (word as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (secret as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (player as NSString).utf8String, -1, nil)
            sqlite3_bind_int(statement, 4, Int32(score))

            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error saving solved word")
            }
        }

        sqlite3_finalize(statement)
    }
}

