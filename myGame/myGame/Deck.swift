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
        Deck(pieces: [.pawn, .knight, .bishop, .rook, .queen, .king])
    }
}
