import SpriteKit
import Foundation

class Hand {
    private var quantityLabel: [PieceType: SKLabelNode] = [:]
    var cards: [Card] = []
    var position: CGPoint
    var columnSpacing: CGFloat = 120
    var cardOverlap: CGFloat = 40
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
    
    func getLabelsToHand() -> [SKLabelNode] {
        return Array(quantityLabel.values)
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
            
            if let firstCard = columnCards.first {
                firstCard.position = CGPoint(x: x, y: position.y)
                firstCard.zPosition = zCounter
                firstCard.isHidden = false
                zCounter += 1
                
                for card in columnCards.dropFirst() {
                    card.isHidden = true
                }
                
                let label: SKLabelNode
                if let existingLabel = quantityLabel[pieceType] {
                    label = existingLabel
                } else {
                    label = SKLabelNode(text: "")
                    label.fontSize = 20
                    label.fontName = "ChineseRocksRg-Regular"
                    label.fontColor = .white
                    quantityLabel[pieceType] = label
                }
                
                let cardTopEdge = position.y + (firstCard.size.height / 2)
                let offset: CGFloat = 4
                
                label.text = "x\(columnCards.count)"
                label.position = CGPoint(x: x, y: cardTopEdge + offset)
                label.zPosition = zCounter + 100

            }
        }
    }
}
