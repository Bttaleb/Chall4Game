//
//  GameScene.swift
//  Chall4
//
//  Created by Bassel Taleb on 1/22/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var cardNode: SKSpriteNode!
    var currentPlayer: Player = .player1
    var selectedCard: Card?
    var dragStartPosition: CGPoint?
    var dragStartZPosition: CGFloat?
    //Store reference to battle slots
    var player1Slot: BattleSlot!
    var player2Slot: BattleSlot!
    var player1Hand: Hand!
    var player2Hand: Hand!
    
    let card: Card?
    let gameArea: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y:0, width: playableWidth, height: size.height)
        
        card = nil
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let slotSize = CGSize(width: 120, height: 100)
        
        player1Slot = BattleSlot(size: slotSize, owner: .player1)
        player1Slot.position = CGPoint(x: gameArea.midX, y: gameArea.height * 0.4)
        addChild(player1Slot)
        
        player2Slot = BattleSlot(size: slotSize, owner: .player2)
        player2Slot.position = CGPoint(x: gameArea.midX, y: gameArea.height * 0.6)
        addChild(player2Slot)
        
        player1Hand = Hand(position: CGPoint(x: gameArea.midX, y: gameArea.height * 0.15))
        player2Hand = Hand(position: CGPoint(x: gameArea.midX, y: gameArea.height * 0.85))
        
        let cardImages = ["3_of_hearts", "2_of_clubs", "ace_of_spades", "king_of_diamonds"]
        for imageName in cardImages {
            let card = Card(frontImage: imageName, backImage: "card_back", attack: 5, defense: 10, abilities: [])
            
            card.setScale(0.4)
            addChild(card)
            player1Hand.addCard(card)
        }
        
        let card = Card(frontImage: "3_of_hearts", backImage: "2_of_clubs", abilities: Set<Ability>())
        cardNode = card
        cardNode.position = CGPoint(x: gameArea.midX, y: gameArea.midY)
        cardNode.setScale(1)
        addChild(cardNode)
        
        card.addFloatyAnimation()
    }
    
    // "Began" fires when finger first touches screen, use nodes(at:) to find WHAT is under touch point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let card = node as? Card {
                selectedCard = card
                dragStartPosition = card.position
                dragStartZPosition = card.zPosition
                card.zPosition = 100
                
                card.removeAction(forKey: "selectedSway")
                break
            }
        }
    }
    
    // "Moved" fires repeatedly as finger moves, update card's position to follow
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let card = selectedCard else { return }
        
        let location = touch.location(in: self)
        card.position = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let card = selectedCard,
              let startPos = dragStartPosition else { return }
        
        let dx = card.position.x - startPos.x
        let dy = card.position.y - startPos.y
        let distance = sqrt(dx * dx + dy * dy)
        
        if distance < 10 {
            card.flip()
        } else {
            if let oldSlot = card.currentSlot {
                oldSlot.isOccupied = false
                card.currentSlot = nil
            }
            
            if let newSlot = battleSlotUnderCard(card) {
                player1Hand.removeCard(_card: card)
                card.position = newSlot.position
                newSlot.isOccupied = true
                card.currentSlot = newSlot
            } else {
                if !player1Hand.cards.contains(card) {
                    player1Hand.addCard(card)
                } else {
                    card.position = startPos
                }
            }
        }
        
        card.zPosition = dragStartZPosition ?? 0
        dragStartZPosition = nil
        card.addFloatyAnimation()
        selectedCard = nil
        dragStartPosition = nil
    }
    
    func battleSlotUnderCard(_ card: Card) -> BattleSlot? {
        if player1Slot.frame.intersects(card.frame) && !player1Slot.isOccupied {
            return player1Slot
        }
        if player2Slot.frame.intersects(card.frame) && !player2Slot.isOccupied {
            return player2Slot
        }
        return nil
    }
    
   
}
