import SpriteKit
import Foundation

class Hand {
    var cards: [Card] = []
    var position: CGPoint
    var cardOffset: CGFloat = 30
    
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
        for (index, card) in cards.enumerated() {
            let yOffset = CGFloat(index) * cardOffset
            card.position = CGPoint(x: position.x, y: position.y - yOffset)
            
            card.zPosition = CGFloat(index)
        }
    }
}
