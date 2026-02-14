//
//  turnBanner.swift
//  myGame
//
//  Created by Abdallah Hussein on 2/14/26.
//

import SpriteKit


class TurnBanner {
    weak var scene: SKScene?
    
    init(scene: SKScene) {
        self.scene = scene
    }
    
    func showBanner(for player: Player) {
        guard let scene = scene else { return }

        let text = player == .player1 ? "Player 1's Turn" : "Player 2's Turn"
        let label = SKLabelNode(text: text)
        label.fontName = "ChineseRocksRg-Regular"
        label.fontSize = 70
        label.fontColor = player == .player1 ? .white : .white
        label.zPosition = 200
        let bannerY = player == .player1 ? scene.size.height * 0.30 : scene.size.height * 0.70
        label.position = CGPoint(x: -label.frame.width, y: bannerY)
        scene.addChild(label)

        let slideIn = SKAction.moveTo(x: scene.size.width / 2, duration: 2)
        slideIn.timingMode = .easeOut
        let hold = SKAction.wait(forDuration: 1.0)
        let slideOut = SKAction.moveTo(x: scene.size.width + label.frame.width,
    duration: 0.4)
        slideOut.timingMode = .easeIn
        let remove = SKAction.removeFromParent()

        label.run(SKAction.sequence([slideIn, hold, slideOut, remove]))
    }
    
}
