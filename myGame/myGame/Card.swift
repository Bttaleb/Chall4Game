import SpriteKit
import SwiftUI

class Card: SKSpriteNode {
    // MARK: Properties
    let frontTexture: SKTexture
    let backTexture: SKTexture
    @State var isFaceUp: Bool = true
    
    // MARK: Initialize
    init(frontImage: String, backImage: String, isFaceUp: Bool = true) {
        self.frontTexture = SKTexture(imageNamed: frontImage)
        self.backTexture = SKTexture(imageNamed: backImage)
        
        //size comes from the texture itself (size isn't set in the code)
        super.init(texture: frontTexture, color:.clear, size: frontTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Animations
    func flip() {
        
        guard action(forKey: "flip") == nil else { return }
        
        let firstHalf = SKAction.scaleX(to: 0, duration: 0.15)
        firstHalf.timingMode = .easeIn
        
        let swapTexture = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.isFaceUp.toggle()
            self.texture = self.isFaceUp ? self.frontTexture : self.backTexture
        }
        
        let secondHalf = SKAction.scaleX(to: 1, duration: 0.15)
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

