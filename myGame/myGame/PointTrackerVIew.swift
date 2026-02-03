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
    
    let barWidth : CGFloat
    let barHeight: CGFloat = 20
    
    init(pointTracker: PointTracker, width: CGFloat) {
        self.pointTracker = pointTracker
        self.barWidth = width
        super.init()
        backgroundBar = SKSpriteNode(color: .darkGray, size: CGSize(width: barWidth, height: barHeight))
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateBar() {
        let percentage = pointTracker.fillPercentage
        fillBar.size.width = barWidth * CGFloat(percentage)
        
    }
}

//swap to custom art
//backgroundBar = SKSpriteNode(imageNamed: "your_background_bar")
//fillBar = SKSpriteNode(imageNamed: "your_fill_bar")
