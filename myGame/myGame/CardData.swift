//
//  File.swift
//  myGame
//
//  Created by Bassel Taleb on 1/30/26.
//
import Foundation

struct CardData {
    let name: String
    let attack: Int
    let defense: Int
    let abilities: Set<Ability>
    let pieceType: PieceType
    
    init(pieceType: PieceType) {
        self.name = pieceType.name
        self.attack = pieceType.baseStats.attack
        self.defense = pieceType.baseStats.defense
        self.abilities = pieceType.baseStats.abilities
        self.pieceType = pieceType
    }
}



