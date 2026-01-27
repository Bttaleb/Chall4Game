//
//  Battle.swift
//  myGame
//
//  Created by Bassel Taleb on 1/26/26.
//
import SpriteKit

class BattleSlot: SKShapeNode {
    var isOccupied: Bool = false
    var slotOwner: Player
}

func battleSlotUnderCard(_ card: Card) -> BattleSlot? {
    if playerSlot.frame.interesects(card.frame) {
        return playerSlot
    }
    return nil
}
