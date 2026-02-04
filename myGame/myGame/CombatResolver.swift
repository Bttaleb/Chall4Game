//
//  CombatResolver.swift
//  myGame
//
//  Created by Bassel Taleb on 2/3/26.
//

import Foundation

struct CombatResolver {
    static func resolve(p1Cards: [Card?], p2Cards: [Card?], p1Health: HealthBar, p2Health: HealthBar) -> CombatResult {
        let matchupCount = min(p1Cards.count, p2Cards.count)
        
        var totalP1DamageTaken = 0
        var totalP2DamageTaken = 0
        
        for i in 0..<matchupCount {
            guard let p1Card = p1Cards[i], let p2Card = p2Cards[i] else { continue }
            
            // shield protects the card in the same slot
            let p1ShieldActive = p1Card.abilities.contains(.shield)
            let p2ShieldActive = p2Card.abilities.contains(.shield)
            
            //calc damage — p1's shield reduces p2's attack on this slot, and vice versa
            let p1Breakdown = calculateDamage(attacker: p1Card, defender: p2Card, hasActiveShield: p2ShieldActive)
            let p2Breakdown = calculateDamage(attacker: p2Card, defender: p1Card, hasActiveShield: p1ShieldActive)
            
            let dmgToP2 = p1Breakdown.finalDamage
            let dmgToP1 = p2Breakdown.finalDamage
            
            p2Health.reduceHP(dmgToP2)
            p1Health.reduceHP(dmgToP1)
            
            print("Slot \(i): \(p1Card.pieceType.name) vs \(p2Card.pieceType.name)")
            if p2Breakdown.wasShielded {
                print("  ⛨ P1's \(p1Card.pieceType.name) shields: P2's attack reduced \(p2Breakdown.preShieldDamage) → \(dmgToP1)")
            }
            if p1Breakdown.wasShielded {
                print("  ⛨ P2's \(p2Card.pieceType.name) shields: P1's attack reduced \(p1Breakdown.preShieldDamage) → \(dmgToP2)")
            }
            applyLifesteal(card: p1Card, damage: dmgToP2, health: p1Health)
            applyLifesteal(card: p2Card, damage: dmgToP1, health: p2Health)
            
            print("  P1 deals \(dmgToP2) to P2 | P2 deals \(dmgToP1) to P1")
            print("  P1 HP: \(p1Health.currentHP) | P2 HP: \(p2Health.currentHP)")
        
            totalP1DamageTaken += dmgToP1
            totalP2DamageTaken += dmgToP2
            
        }
        return CombatResult(
            player1DamageTaken: totalP1DamageTaken,
            player2DamageTaken: totalP2DamageTaken,
            player1CardsUsed: p1Cards.compactMap { $0 },
            player2CardsUsed: p2Cards.compactMap { $0 }
        )
    }
    
    struct DamageBreakdown {
        let finalDamage: Int
        let baseDamage: Int
        let wasShielded: Bool
        let preShieldDamage: Int
    }
    
    private static func calculateDamage(attacker: Card, defender: Card, hasActiveShield: Bool) -> DamageBreakdown {
    
        var damage = max(0, attacker.attack - defender.defense)
        
        if attacker.abilities.contains(.pierce) {
            damage = attacker.attack
        }
        
        if attacker.abilities.contains(.doublestrike) {
            damage = damage * 2
        }
        
        let preShieldDamage = damage
                
        if hasActiveShield {
            damage = damage / 2
        }
        
        return DamageBreakdown(
            finalDamage: damage,
            baseDamage: attacker.attack,
            wasShielded: hasActiveShield,
            preShieldDamage: preShieldDamage
        )
    }
    
    //lifesteal helper
    static func applyLifesteal(card: Card, damage: Int, health: HealthBar) {
        if card.abilities.contains(.lifesteal) && damage > 0 {
            let healAmount = card.attack / 2
            health.heal(healAmount)
            print("Lifesteal: healed \(healAmount)")
        }
    }
}
