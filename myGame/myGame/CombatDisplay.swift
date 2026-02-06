//
//  CombatDisplay.swift
//  myGame
//
//  Created by Abdallah Hussein on 2/4/26.
//

import Foundation
import SpriteKit


class CombatDisplay {
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func showDamage(_ Damage: Int, position: CGPoint, isPlayer1: Bool) {
        guard let scene = scene else { return }
        let label = SKLabelNode(text: "-\(Damage)")
        label.fontName = "ChineseRocksRg-Regular"
        label.fontSize = 200
        label.position = position
        label.zPosition = 200
        label.fontColor = isPlayer1 ? .red : .blue  
        scene.addChild(label)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        
        let fadeOut = SKAction.fadeOut(withDuration: 4.0)
        
        let remove = SKAction.removeFromParent()
        
        label.run(SKAction.sequence([SKAction.group([moveUp, fadeOut]), remove]))
        
    }

        
}
