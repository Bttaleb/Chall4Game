//
//  CombatAnimations.swift
//  myGame
//
//  Created by Abdallah Hussein on 2/14/26.
//

import SpriteKit

struct CombatAnimations {

    // attack animation based on card type
    // direction: 1 for P1 (lunge up), -1 for P2 (lunge down)
    static func attackAnimation(for card: Card, origin: CGPoint, direction: CGFloat) -> SKAction {
        let abilities = card.abilities

        // Shield cards Bishop/Rook/King — defend pulse, no lunge
        if card.attack == 0 && abilities.contains(.shield) {
            let scaleUp = SKAction.scale(to: 0.35, duration: 0.15)
            let flash = SKAction.sequence([
                SKAction.colorize(with: .yellow, colorBlendFactor: 0.6, duration: 0.1),
                SKAction.colorize(withColorBlendFactor: 0, duration: 0.1)
            ])
            let scaleDown = SKAction.scale(to: 0.3, duration: 0.15)
            return SKAction.sequence([SKAction.group([scaleUp, flash]), scaleDown])
        }

        // Knight pierce  fast dash through enemy
        if abilities.contains(.pierce) {
            let dash = SKAction.moveBy(x: 0, y: direction * 120, duration: 0.12)
            dash.timingMode = .easeIn
            let returnMove = SKAction.move(to: origin, duration: 0.2)
            returnMove.timingMode = .easeOut
            return SKAction.sequence([dash, returnMove])
        }

        // Queen lifesteal — big heavy lunge with scale up
        if abilities.contains(.lifesteal) {
            let windUp = SKAction.scale(to: 0.35, duration: 0.15)
            let lunge = SKAction.moveBy(x: 0, y: direction * 80, duration: 0.3)
            lunge.timingMode = .easeIn
            let returnMove = SKAction.move(to: origin, duration: 0.25)
            returnMove.timingMode = .easeOut
            let scaleBack = SKAction.scale(to: 0.3, duration: 0.15)
            return SKAction.sequence([windUp, lunge, SKAction.group([returnMove, scaleBack])])
        }

        // Pawn 5 attack — small quick lunge
        let lunge = SKAction.moveBy(x: 0, y: direction * 40, duration: 0.2)
        lunge.timingMode = .easeOut
        let returnMove = SKAction.move(to: origin, duration: 0.2)
        returnMove.timingMode = .easeOut
        return SKAction.sequence([lunge, returnMove])
    }
}
