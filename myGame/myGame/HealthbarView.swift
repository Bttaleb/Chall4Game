//
//  HealthbarView.swift
//  myGame
//
//  Created by Abdallah Hussein on 1/28/26.
//

import SpriteKit


class HealthbarView: SKNode {

    var healthBar: HealthBar
    var backgroundBar: SKSpriteNode!
    var fillBar: SKSpriteNode!
    var hpLabel: SKLabelNode!


    let barWidth: CGFloat
    let barHeight: CGFloat = 40
    let offset: CGFloat = 20

    init(healthBar: HealthBar, width: CGFloat, fillImageName: String = "healthbarred") {
        self.barWidth = width
        self.healthBar = healthBar
        super.init()
        //custom bar
        backgroundBar = SKSpriteNode(imageNamed: "healthbargold")
        backgroundBar.size = CGSize(width: barWidth, height: barHeight)
        backgroundBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        backgroundBar.zPosition = 0
        addChild(backgroundBar)
        //custom fillable bar
        fillBar = SKSpriteNode(imageNamed: fillImageName)
        fillBar.size = CGSize(width: barWidth, height: barHeight)
        fillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        fillBar.zPosition = 1
        addChild(fillBar)

        hpLabel = SKLabelNode(text: "50 / 50")
        hpLabel.fontName = "ChineseRocksRg-Regular"
        hpLabel.zRotation = .pi / -2
        hpLabel.fontSize = 40
        hpLabel.fontColor = .systemYellow
        hpLabel.position = CGPoint(x: barWidth + 12, y: 0)

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

    func setCombatLayout() {
        hpLabel.zRotation = 0
        hpLabel.position = CGPoint(x: barWidth / 2, y: barHeight)
    }

    func setNormalLayout() {
        hpLabel.zRotation = .pi / -2
        hpLabel.position = CGPoint(x: barWidth + 12, y: 0)
    }
}
