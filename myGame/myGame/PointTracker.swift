//
//  K&Qbar.swift
//  myGame
//
//  Created by Abdallah Hussein on 1/28/26.
//

import Foundation

class PointTracker {
    var currentPoints: Int
    let maxPoints: Int

    init(maxPoints: Int = 40) {
        self.currentPoints = 0
        self.maxPoints = maxPoints
    }

    func addPoints(_ amount: Int) {
        currentPoints = max(0, min(maxPoints, currentPoints + amount))
    }

    var isUnlocked: Bool {
        return currentPoints >= maxPoints
    }

    var fillPercentage: Double {
        return Double(currentPoints) / Double(maxPoints)
    }

    func reset() {
        currentPoints = 0
    }
}
