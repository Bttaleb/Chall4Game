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
        let card = Card(frontImage: "3_of_hearts", backImage: "2_of_clubs")
        cardNode = card
        cardNode.position = CGPoint(x: gameArea.midX, y: gameArea.midY)
        cardNode.setScale(0.5)
        addChild(cardNode)
        
        card.addFloatyAnimation()
    }
    
    func flipCard() {
        let changeTexture = SKAction.scaleX(to: 0, duration: 0.15)
        let flipOut = SKAction.setTexture(SKTexture(imageNamed: "3_of_hearts"))
        let flipIn = SKAction.scaleX(to: 0.5, duration: 0.15)
        cardNode.run(SKAction.sequence([flipOut, changeTexture, flipIn]))
    }
   
}
