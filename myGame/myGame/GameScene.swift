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
    var selectedCard: Card?
    var dragStartPosition: CGPoint?
    //Store reference to battle slots
    var player1Slot: BattleSlot!
    var player2Slot: BattleSlot!
    
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
        player1Slot.position = CGPoint(x: gameArea.midX, y: gameArea.height * 0.25)
        addChild(player1Slot)
        
        player2Slot = BattleSlot(size: slotSize, owner: .player2)
        player2Slot.position = CGPoint(x: gameArea.midX, y: gameArea.height * 0.75)
        addChild(player2Slot)
        
        
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
            if let slot = battleSlotUnderCard(card) {
                slot.isOccupied = true
            } else {
                card.position = startPos
            }
        }
        
        card.zPosition = 0
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
