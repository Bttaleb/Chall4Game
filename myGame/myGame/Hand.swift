import SpriteKit
import Foundation

class Hand {
    var cards: [Card] = []
    var position: CGPoint
    var columnSpacing: CGFloat = 240
    var cardOverlap: CGFloat = 80
    
    // piece type ordering for columns, left to right
    private let columnOrder: [PieceType] = [.pawn, .knight, .bishop, .rook, .queen, .king]
    
    init(position: CGPoint) {
        self.position = position
    }
    
    func addCard(_ card: Card) {
        cards.append(card)
        layoutCards()
    }
    
    func removeCard(_card: Card) {
        if let index = cards.firstIndex(of: _card) {
            cards.remove(at: index)
            layoutCards()
        }
    }
    
    func layoutCards() {
        // group cards by piece type
        var groups: [PieceType: [Card]] = [:]
        for card in cards {
            groups[card.pieceType, default: []].append(card)
        }
        
        // only layout columns that have cards
        let activeColumns = columnOrder.filter { groups[$0] != nil }
        let totalColumns = CGFloat(activeColumns.count)
        let totalWidth = (totalColumns - 1) * columnSpacing
        let startX = position.x - totalWidth / 2
        
        var zCounter: CGFloat = 0
        
        for (colIndex, pieceType) in activeColumns.enumerated() {
            guard let columnCards = groups[pieceType] else { continue }
            let x = startX + CGFloat(colIndex) * columnSpacing
            
            for (rowIndex, card) in columnCards.enumerated() {
                let yOffset = CGFloat(rowIndex) * cardOverlap
                card.position = CGPoint(x: x, y: position.y - yOffset)
                card.zPosition = zCounter
                zCounter += 1
            }
        }
    }
}
