//
//  health.swift
//  myGame
//
//  Created by Abdallah Hussein on 1/27/26.
//

import SpriteKit
import Foundation
import SwiftUI

struct HealthBar {
    var currentHP: Int
    let maxHP: Int
    
    //subtracts from health
    mutating func reduceHP (_ amount: Int) {
        currentHP = max(0, currentHP - amount)
    
    }
    //take damage but also never go below 0 if defense > attack
    mutating func takeDamage (_ amount: Int, defense: Int){
        let actualDamage = max(0, amount - defense)
              reduceHP(actualDamage)
    }
    //checks to see if anyone at 0 after each round read and calculate
    var isDead: Bool {
        return currentHP <= 0
    }
    //mutating func heal()??
    
  //  var healthPercentage: Double {
   //     return Double
    
    
}

