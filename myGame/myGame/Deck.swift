//
//  Deck.swift
//  myGame
//
//  Created by Bassel Taleb on 2/2/26.
//

import Foundation
struct Deck {
    private(set) var cards: [CardData]
    init(pieces: [PieceType]) {
        self.cards = pieces.map {
            CardData(pieceType: $0) }
        self.cards.shuffle()
    }
    mutating func draw(_ count: Int) -> [CardData] {
        let drawnCount = min(count, cards.count)
        let drawnCards = Array(cards.prefix(drawnCount))
        cards.removeFirst(drawnCount)
        return drawnCards
    }
    var isEmpty: Bool {
        cards.isEmpty
    }
    var remaining: Int {
        cards.count
    }
}

struct DeckBuilder {
    static func standardDeck() -> Deck {
        let pieces: [(PieceType, Int)] = [
            (.pawn, 8),
            (.knight, 2),
            (.bishop, 2),
            (.rook, 2),
            (.queen, 1),
            (.king, 1)
        ]
        
        var allPieces: [PieceType] = []
        
        for (piece, count) in pieces {
            Array(repeating: piece, count: count).forEach { allPieces.append($0) }
        }
        
        return Deck(pieces: allPieces)
    }
}
