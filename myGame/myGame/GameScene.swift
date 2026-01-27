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
        let card = Card(frontImage: "3_of_hearts", backImage: "2_of_clubs", abilities: Set<Ability>())
        cardNode = card
        cardNode.position = CGPoint(x: gameArea.midX, y: gameArea.midY)
        cardNode.setScale(0.5)
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
        guard let card = selectedCard else { return }
        
        if let slot = battleSlotUnderCard(card) {
            card.position = slot.position
        }
        
        card.zPosition = 0
        card.addFloatyAnimation()
        selectedCard = nil
    }
    
    
    func flipCard() {
        let changeTexture = SKAction.scaleX(to: 0, duration: 0.15)
        let flipOut = SKAction.setTexture(SKTexture(imageNamed: "3_of_hearts"))
        let flipIn = SKAction.scaleX(to: 0.5, duration: 0.15)
        cardNode.run(SKAction.sequence([flipOut, changeTexture, flipIn]))
    }
   
}
