//
//  health.swift
//  myGame
//
//  Created by Abdallah Hussein on 1/27/26.
//

import Foundation

class HealthBar {
    var currentHP: Int
    let maxHP: Int

    // Initialize with starting HP
    init(maxHP: Int) {
        self.maxHP = maxHP
        self.currentHP = maxHP  // start at full health
    }

    // Subtracts from health, can't go below 0
    func reduceHP(_ amount: Int) {
        currentHP = max(0, currentHP - amount)
    }

    // Take damage but defense reduces it, never below 0
    func takeDamage(_ amount: Int, defense: Int) {
        let actualDamage = max(0, amount - defense)
        reduceHP(actualDamage)
    }

    // Checks if dead after each round
    var isDead: Bool {
        return currentHP <= 0
    }

    // Returns 0.0 to 1.0 for display
    var healthPercentage: Double {
        return Double(currentHP) / Double(maxHP)
    }

    // Heal but don't go over max
    func heal(_ amount: Int) {
        currentHP = min(maxHP, currentHP + amount)
    }
}
