//
//  File.swift
//  myGame
//
//  Created by Bassel Taleb on 1/30/26.
//


let frontTexture: SKTexture
    let backTexture: SKTexture
    var attack: Int = 0
    var defense: Int = 0
    var abilities: Set<Ability> = []
    
    var isFaceUp: Bool = true
    var currentSlot: BattleSlot?
    
    // MARK: Initialize Card
    init(frontImage: String, backImage: String, attack: Int = 0, defense: Int = 0, abilities: Set<Ability>) {
        
        self.attack = attack
        self.defense = defense
        self.abilities = abilities
        
        self.frontTexture = SKTexture(imageNamed: frontImage)
        self.backTexture = SKTexture(imageNamed: backImage)
        
        
        //size comes from the texture itself (size isn't set in the code)
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }