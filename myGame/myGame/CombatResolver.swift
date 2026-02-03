//
//  CombatResolver.swift
//  myGame
//
//  Created by Bassel Taleb on 2/3/26.
//

import Foundation

struct CombatResolver {
    static func resolve(p1Cards: [Card], p2Cards: [Card], p1Health: HealthBar, p2Health: HealthBar) -> CombatResult {
        let matchupCount = min(p1Cards.count, p2Cards.count)
        var p1ShieldActive = false
        var p2ShieldActive = false
        
        var totalP1DamageTaken = 0
        var totalP2DamageTaken = 0
        
        for i in 0..<matchupCount {
            let p1Card = p1Cards[i]
            let p2Card = p2Cards[i]
            
            //calc damage using shield state
            let dmgToP2 = calculateDamage(attacker: p1Card, defender: p2Card, hasActiveShield: p2ShieldActive)
            let dmgToP1 = calculateDamage(attacker: p2Card, defender: p1Card, hasActiveShield: p1ShieldActive)
            
            p2Health.reduceHP(dmgToP2)
            p1Health.reduceHP(dmgToP1)
            
            applyLifesteal(card: p1Card, damage: dmgToP2, health: p1Health)
            applyLifesteal(card: p2Card, damage: dmgToP1, health: p2Health)
            
            p1ShieldActive = p1Card.abilities.contains(.shield)
            p2ShieldActive = p2Card.abilities.contains(.shield)
            
            totalP1DamageTaken += dmgToP1
            totalP2DamageTaken += dmgToP2
            
        }
        return CombatResult(
            player1DamageTaken: totalP1DamageTaken,
            player2DamageTaken: totalP2DamageTaken,
            player1CardsUsed: p1Cards,
            player2CardsUsed: p2Cards
        )
    }
    
    private static func calculateDamage(attacker: Card, defender: Card, hasActiveShield: Bool) -> Int {
    
        let defenderHasShield = hasActiveShield
        var damage = max(0, attacker.attack - defender.defense)
        
        if attacker.abilities.contains(.pierce) {
            damage = attacker.attack
        }
        
        if attacker.abilities.contains(.doublestrike) {
            damage = damage * 2
        }
                
        if defenderHasShield == true {
            damage = damage / 2
        }
        
        return damage
    }
    
    //lifesteal helper
    static func applyLifesteal(card: Card, damage: Int, health: HealthBar) {
        if card.abilities.contains(.lifesteal) && damage > 0 {
            health.heal(damage / 2)
        }
    }
}
