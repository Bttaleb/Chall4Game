//
//  HealthbarView.swift
//  myGame
//
//  Created by Abdallah Hussein on 1/28/26.
//

import SpriteKit


class HealthbarView: SKNode {
    
    var healthBar: HealthBar
    private var backgroundBar: SKSpriteNode!
    private var fillBar: SKSpriteNode!
    private var hpLabel: SKLabelNode!
    
    
    let barWidth: CGFloat
    let barHeight: CGFloat = 20

    init(healthBar: HealthBar, width: CGFloat) {
        self.barWidth = width
        self.healthBar = healthBar
        super.init()
        backgroundBar = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: barHeight))
        backgroundBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(backgroundBar)
        fillBar = SKSpriteNode(color: .green, size: CGSize(width: barWidth, height: barHeight))
        fillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(fillBar)
        
        hpLabel = SKLabelNode(text: "100 / 100")
        hpLabel.fontName = "Helvetica-Bold"
        hpLabel.fontSize = 14
        hpLabel.fontColor = .white
        hpLabel.position = CGPoint(x: barWidth + 10, y: 0)
        addChild(hpLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateBar() {
        let percentage = healthBar.healthPercentage
        fillBar.size.width = barWidth * CGFloat(percentage)
        hpLabel.text = "\(healthBar.currentHP) / \(healthBar.maxHP)"
    }
}

//swap to custom art
//backgroundBar = SKSpriteNode(imageNamed: "your_background_bar")
//fillBar = SKSpriteNode(imageNamed: "your_fill_bar")
