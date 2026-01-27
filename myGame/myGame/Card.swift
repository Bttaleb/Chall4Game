import SpriteKit
import SwiftUI

enum Ability {
    case pierce
    case lifesteal
    case doublestrike
}

enum Player {
    case player1
    case player2
}

struct GameState {
    var player1HP: Int = 20
    var player2HP: Int = 20
    
    mutating func dealDamage(to player: Player, amount: Int) {
        switch player {
        case .player1: player1HP = max(0, player1HP - amount)
        case .player2: player2HP = max(0, player2HP - amount)
        }
    }
    
    func isGameOver() -> Bool {
        return player1HP <= 0 || player2HP <= 0
    }
    
}

class Card: SKSpriteNode {
    // MARK: Properties
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var attack: Int = 0
    var defense: Int = 0
    var abilities: Set<Ability> = []
    
    var isFaceUp: Bool = true
    var currentSlot: BattleSlot?
    
    // MARK: Initialize Card
    init(frontImage: String, backImage: String, attack: Int = 0, defense: Int = 0, abilities: Set<Ability>) {
        
        self.attack = attack
        self.defense = defense
        self.abilities = abilities
        
        self.frontTexture = SKTexture(imageNamed: frontImage)
        self.backTexture = SKTexture(imageNamed: backImage)
        
        
        //size comes from the texture itself (size isn't set in the code)
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Animations
    func flip() {
        
        guard action(forKey: "flip") == nil else { return }
        
        let originalScaleX = self.xScale
        
        let firstHalf = SKAction.scaleX(to: 0, duration: 0.15)
        firstHalf.timingMode = .easeIn
        
        let swapTexture = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.isFaceUp.toggle()
            self.texture = self.isFaceUp ? self.frontTexture : self.backTexture
        }
        
        let secondHalf = SKAction.scaleX(to: originalScaleX, duration: 0.15)
        secondHalf.timingMode = .easeOut
        
        let flipSequence = SKAction.sequence([firstHalf, swapTexture, secondHalf])
        run(flipSequence, withKey: "flip")
    }
    
    func addFloatyAnimation() {
        
        let swayRight = SKAction.rotate(byAngle: 0.02, duration: 1.0)
        swayRight.timingMode = .easeInEaseOut
        let swayLeft = SKAction.rotate(byAngle: -0.02, duration: 1.0)
        swayLeft.timingMode = .easeInEaseOut
        let rotationSway = SKAction.sequence([swayLeft, swayRight])
        
        let nudgeRight = SKAction.moveBy(x: 4, y: 0, duration: 0.8)
        nudgeRight.timingMode = .easeInEaseOut
        let nudgeLeft = SKAction.moveBy(x: -4, y: 0, duration: 0.8)
        nudgeLeft.timingMode = .easeInEaseOut
        let horizontalSway = SKAction.sequence([nudgeRight, nudgeLeft])
        
        let combined = SKAction.group([rotationSway, horizontalSway])
        run(SKAction.repeatForever(combined), withKey: "selectedSway")
    }
    
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs == rhs
}
