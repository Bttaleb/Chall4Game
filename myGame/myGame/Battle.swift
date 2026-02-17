//
//  Battle.swift
//  myGame
//
//  Created by Bassel Taleb on 1/26/26.
//
import SpriteKit

class BattleSlot: SKSpriteNode {
    var isOccupied: Bool = false
    var slotOwner: Player

    
    init(size: CGSize, owner: Player) {
        self.slotOwner = owner
        let imageName = owner == .player1 ? "green_slot" : "yellow_slot"
        super.init(texture: SKTexture(imageNamed: imageName), color: .clear, size: size)
        self.name = "battleSlot"
        self.zPosition = -0.5
    }
    
    
//    init(size: CGSize, owner: Player) {
//        self.slotOwner = owner
//        super.init()
//        
//        let rect = CGRect(
//            x: -size.width / 2,
//            y: -size.height / 2,
//            width: size.width,
//            height: size.height
//        )
//        self.path = CGPath(roundedRect: rect, cornerWidth: 10, cornerHeight: 10, transform: nil)
//        
//        self.strokeColor = owner == .player1 ? .blue : .red
//        self.lineWidth = 6
//        self.fillColor = .clear
//        self.name = "battleSlot"
//    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}


