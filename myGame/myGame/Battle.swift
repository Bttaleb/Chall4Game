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

    
    init(size: CGSize, owner: Player) {
        self.slotOwner = owner
        super.init()
        
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        self.path = CGPath(roundedRect: rect, cornerWidth: 10, cornerHeight: 10, transform: nil)
        
        self.strokeColor = owner == .player1 ? .blue : .red
        self.lineWidth = 3
        self.fillColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
