//
//  Untitled.swift
//  myGame
//
//  Created by Abdallah Hussein on 2/2/26.
//

import SpriteKit

class PointTrackerView: SKNode {
    var pointTracker: PointTracker
    
    
    private var backgroundBar: SKSpriteNode!
    private var fillBar: SKSpriteNode!
    private var outlineBar: SKShapeNode!
    private var pointslabel: SKLabelNode!
    
    let barWidth : CGFloat
    let barHeight: CGFloat = 20
    
    init(pointTracker: PointTracker, width: CGFloat) {
        self.pointTracker = pointTracker
        self.barWidth = width
        super.init()
        backgroundBar = SKSpriteNode(color: .clear, size: CGSize(width: barWidth, height: barHeight))
        backgroundBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(backgroundBar)
        fillBar = SKSpriteNode(color:.yellow, size: CGSize (width: 0, height: barHeight))
        fillBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(fillBar)
        outlineBar = SKShapeNode(rect: CGRect(x:0, y: -barHeight / 2, width: barWidth, height: barHeight))
        outlineBar.strokeColor = .yellow
        outlineBar.lineWidth = 2
        outlineBar.fillColor = .clear
        addChild(outlineBar)
        
        pointslabel = SKLabelNode(text: "0/40")
        pointslabel.fontColor = .yellow
        pointslabel.position = CGPoint(x: barWidth + 32, y: -8)
        pointslabel.fontName = "ChineseRocksRg-Regular"
        pointslabel.fontSize = 20
        addChild(pointslabel)

        // Title label above the bar
        let titleLabel = SKLabelNode(text: "POWER")
        titleLabel.fontName = "ChineseRocksRg-Regular"
        titleLabel.fontSize = 16
        titleLabel.fontColor = .yellow
        titleLabel.horizontalAlignmentMode = .left
        titleLabel.position = CGPoint(x: 0, y: barHeight / 2 + 4)
        addChild(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateBar() {
        let percentage = pointTracker.fillPercentage
        let newWidth = barWidth * CGFloat(percentage)
        fillBar.size.width = newWidth
        pointslabel.text = "\(pointTracker.currentPoints) / \(pointTracker.maxPoints)"

        // Color shifts as bar fills
        if percentage < 0.5 {
            fillBar.color = .yellow
        } else if percentage < 0.83 {
            fillBar.color = .orange
        } else if !pointTracker.isUnlocked {
            fillBar.color = UIColor(red: 1.0, green: 0.3, blue: 0.1, alpha: 1.0)
        } else {
            fillBar.color = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
            outlineBar.strokeColor = UIColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0)
        }
    }
}

//swap to custom art
//backgroundBar = SKSpriteNode(imageNamed: "your_background_bar")
//fillBar = SKSpriteNode(imageNamed: "your_fill_bar")
