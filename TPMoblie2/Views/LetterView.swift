//
//  LetterView.swift
//  TPMoblie2
//
//  Created by cedrick Gaumond-Dupuis on 2024-11-23.
//
import SwiftUI

struct LetterView: View {
    let letter: Character
    
    var body: some View {
        Text(String(letter))
            .font(.title)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.2)))
            .draggable(String(letter))
    }
}
