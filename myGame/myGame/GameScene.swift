//
//  GameScene.swift
//  Chall4
//
//  Created by Bassel Taleb on 1/22/26.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var cardNode: SKSpriteNode!
    private var bg: SKSpriteNode!
    private var bgeffects: SKEffectNode!
    
    var turnManager: TurnManager!
    
    var currentHand: Hand {
        return currentPlayer == .player1 ? player1Hand : player2Hand
    }
    var p1Health: HealthBar!
    var p2Health: HealthBar!
    var p1HBView: HealthbarView!
    var p2HBView: HealthbarView!
    
    var currentPlayer: Player = .player1
    var player1Deck: Deck!
    var player2Deck: Deck!
    var player1PlayedPoints: Int = 0
    var player2PlayedPoints: Int = 0
    var player1PlacedCards: [Card?] = Array(repeating: nil, count: 4)
    var player2PlacedCards: [Card?] = Array(repeating: nil, count: 4)
    var currentPlacedCards: [Card?] {
        return currentPlayer == .player1 ? player1PlacedCards : player2PlacedCards
    }
    
    var selectedCard: Card?
    var dragStartPosition: CGPoint?
    var dragStartZPosition: CGFloat?
    //Store reference to battle slots -> into arrays (multiple slots)
    var player1Slots: [BattleSlot] = []
    var player2Slots: [BattleSlot] = []
    var currentSlots: [BattleSlot] {
        return currentPlayer == .player1 ? player1Slots : player2Slots
    }
    var playerIsReady: Bool? = false
    var player1Hand: Hand!
    var player2Hand: Hand!
    var gameTurns: Int = 0
    var player1Turn: Int = 0
    var player2Turn: Int = 0
    
    //declaring ready up button
    var readyUp: SKSpriteNode!
    
    //displays combat numbers
    var combatDisplay: CombatDisplay!
    
    //displaus players turn
    var turnBanner: TurnBanner!
    
    //store ref to point trackers
    var p1TrackerView: PointTrackerView!
    var p2TrackerView: PointTrackerView!
    
    
    let card: Card?
    var gameArea: CGRect
        
    //padding for HB AND PT
    let padding: CGFloat = 30
    
    override init(size: CGSize) {
        gameArea = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        card = nil
        super.init(size: size)
        recalculateGameArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func recalculateGameArea() {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
    }
    
    func dealHand(for player: Player) {
        var deck = player == .player1 ? player1Deck : player2Deck
        guard deck != nil else {return}
        
        let drawnCardData = deck!.draw(deck!.remaining)
        
        if player == .player1 {
            player1Deck = deck
        } else {
            player2Deck = deck
        }
        
        let hand = player == .player1 ? player1Hand : player2Hand
        
        for cardData in drawnCardData {
            let card = Card(data: cardData)
            
            //locking King and queen
            if  card.pieceType == .king || card.pieceType == .queen {
                card.applyLock()
            }

            if player == .player2 {
                card.isHidden = true
            }
            addChild(card)
            hand?.addCard(card)
        }
    }
    
    override func didMove(to view: SKView) {
        bg = SKSpriteNode(imageNamed: "Final_Background")
        bg.zPosition = -1
        //EFFECT TO BLUR BACKGROUND WHEN COMBAT STARTS
        bgeffects = SKEffectNode()
        bgeffects.addChild(bg)
        addChild(bgeffects)
        bgeffects.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 10])
        bgeffects.shouldEnableEffects = false
        
        turnManager = TurnManager(cardsPerTurn: 4)
        turnManager.delegate = self
        
        let slotSize = CGSize(width: 80, height: 120)
        
        //make player1's slots
        for _ in 0..<4 {
            let slot = BattleSlot(size: slotSize, owner: .player1)
            addChild(slot)
            player1Slots.append(slot)
        }
        
        for _ in 0..<4 {
            let slot = BattleSlot(size: slotSize, owner: .player2)
            addChild(slot)
            player2Slots.append(slot)
        }
        
        // Health bar displays
        p1Health = HealthBar(maxHP: 50)
        p1HBView = HealthbarView(healthBar: p1Health, width: size.width * 0.4, fillImageName: "healthbarred")
        addChild(p1HBView)

        p2Health = HealthBar(maxHP: 50)
        p2HBView = HealthbarView(healthBar: p2Health, width: size.width * 0.4, fillImageName: "healthbar_blue")
        addChild(p2HBView)

        // Point trackers
        let p1Tracker = PointTracker()
        p1TrackerView = PointTrackerView(pointTracker: p1Tracker, width: size.width * 0.2)
        addChild(p1TrackerView)

        let p2Tracker = PointTracker()
        p2TrackerView = PointTrackerView(pointTracker: p2Tracker, width: size.width * 0.2)
        addChild(p2TrackerView)
        p2TrackerView.isHidden = true

        //combat displays
        combatDisplay = CombatDisplay(scene: self)
        
        turnBanner = TurnBanner(scene: self)
        
        player1Hand = Hand(position: .zero)
        player2Hand = Hand(position: .zero)
        
        player1Deck = DeckBuilder.standardDeck()
        player2Deck = DeckBuilder.standardDeck()
        
        layoutUI()
        
        dealHand(for: .player1)
        dealHand(for: .player2)

        // Add quantity labels to scene
        for label in player1Hand.getLabelsToHand() {
            addChild(label)
        }

        for label in player2Hand.getLabelsToHand() {
            addChild(label)
            label.isHidden = true
        }

        // Ready button
        readyUp = SKSpriteNode(imageNamed: "confirm.png")
        readyUp.name = "readyUp"
        readyUp.position = CGPoint(x: 640, y: size.height * 0.15 + 140)
        readyUp.size = CGSize(width: 320, height: 72)
        addChild(readyUp)

        // Start the game
        turnManager.startGame()
        
        turnBanner.showBanner(for: .player1)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        recalculateGameArea()
        layoutUI()
    }
    
    func layoutUI() {
        // Background
        bg?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg?.size = size
        
        // Battle slots
        let slotSpacing: CGFloat = 160
        let totalWidth = slotSpacing * 3
        let startX = gameArea.midX - totalWidth / 2
        let endX = startX + totalWidth
        for (i, slot) in player1Slots.enumerated() {
            slot.position = CGPoint(
                x: startX + CGFloat(i) * slotSpacing,
                y: gameArea.midY
            )
        }
        for (i, slot) in player2Slots.enumerated() {
            slot.position = CGPoint(
                x: startX + CGFloat(i) * slotSpacing,
                y: gameArea.midY
            )
        }
        
        // Health bars
        let healthBarOffset: CGFloat = 100
        p1HBView?.position = CGPoint(x: startX - healthBarOffset, y: gameArea.midY - healthBarOffset)
        p1HBView?.zRotation = .pi / 2
        p2HBView?.position = CGPoint(x: endX + healthBarOffset, y: gameArea.midY - healthBarOffset)
        p2HBView?.zRotation = .pi / 2

        // Point trackers
        p1TrackerView?.position = CGPoint(x: 20, y: size.height * 0.15 + 180)
        p2TrackerView?.position = CGPoint(x: 20, y: size.height - padding - 10)
        
        // Hands
        player1Hand?.position = CGPoint(x: gameArea.midX, y: size.height * 0.15)
        player1Hand?.layoutCards()
        player2Hand?.position = CGPoint(x: gameArea.midX, y: size.height * 0.85)
        player2Hand?.layoutCards()
        
//        // Ready button
//        let readyUp = SKSpriteNode(imageNamed: "confirm.png")
//        readyUp.name = "readyUp"
//        readyUp.position = CGPoint(x: 640, y: size.height * 0.15 + 140)
//        readyUp.size = CGSize(width: 320, height: 72)
//        addChild(readyUp)
        
        //allowing screen to rotate and button will look fine
        readyUp?.position = CGPoint(x: 640, y: size.height * 0.15 + 140)
    }
    
    // "Began" fires when finger first touches screen, use nodes(at:) to find WHAT is under touch point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard turnManager.currentPhase == .placing else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let card = node as? Card {
                if currentHand.cards.contains(card) || card.currentSlot != nil {
                    selectedCard = card
                    dragStartPosition = card.position
                    dragStartZPosition = card.zPosition
                    card.zPosition = 100
                    card.removeAction(forKey: "selectedSway")
                    break
                }
            }
        }
    }
    
    // "Moved" fires repeatedly as finger moves, update card's position to follow -> Cards move when you pick them up
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first,
              let card = selectedCard else { return }
        
        let location = touch.location(in: self)
        card.position = location
        card.addFloatyAnimation()
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard turnManager.currentPhase == .placing else { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNode = atPoint(location)
        if tappedNode.name == "readyUp" && currentSlots.filter({$0.isOccupied}).count == 4 {
            turnManager.handleTurnComplete()
        }
        
        guard let card = selectedCard,
        let startPos = dragStartPosition else { return }
        let isNearHand = abs(card.position.y - currentHand.position.y) < 150

        let dx = card.position.x - startPos.x
        let dy = card.position.y - startPos.y
        let distance = sqrt(dx * dx + dy * dy)
        
        //flip if a tap
        if distance < 10 {
            card.flip()
        } else { //append
            if let newSlot = battleSlotUnderCard(card) {
                if let oldSlot = card.currentSlot {
                    oldSlot.isOccupied = false
                    card.currentSlot = nil
                }
                guard canPlay(card) else {
                    card.position = startPos
                    card.zPosition = dragStartZPosition ?? 0
                    dragStartZPosition = nil
                    selectedCard = nil
                    dragStartPosition = nil
                    return
                }
                
                currentHand.removeCard(_card: card)
                card.position = newSlot.position
                newSlot.isOccupied = true
                card.currentSlot = newSlot
                
                if currentPlayer == .player1 {
                    if let slotIndex = currentSlots.firstIndex(of: newSlot) {
                        player1PlacedCards[slotIndex] = card
                    }
                    //adds points to p1 point tracker
                    let points = card.attack + card.defense
                    p1TrackerView.pointTracker.addPoints(points)
                    player1PlayedPoints += points
                    p1TrackerView.updateBar()
                    print("\(currentPlayer) placed: \(card.pieceType.name) w/ ATK \(card.attack), DEF \(card.defense), current played points: \(player1PlayedPoints)")
                    if p1TrackerView.pointTracker.isUnlocked {
                        for card in player1Hand.cards {
                            if card.pieceType == .king || card.pieceType == .queen {
                                card.removeLock()
                            }
                        }
                    }

                }
                                
                if currentPlayer == .player2 {
                    if let slotIndex = currentSlots.firstIndex(of: newSlot) {
                        player2PlacedCards[slotIndex] = card
                    }
                    //add points to p2 point tracker
                    let points = card.attack + card.defense
                    p2TrackerView.pointTracker.addPoints(points)
                    player2PlayedPoints += points
                    p2TrackerView.updateBar()
                    print("\(currentPlayer) placed: \(card.pieceType.name) w/ ATK \(card.attack), DEF \(card.defense)")
                    if p2TrackerView.pointTracker.isUnlocked {
                        for card in player2Hand.cards {
                            if card.pieceType == .king || card.pieceType == .queen {
                                card.removeLock()
                            }
                        }
                    }

                }
                
                let filledCount = currentSlots.filter { $0.isOccupied } .count
                
            }
             else if card.currentSlot != nil && isNearHand {
                removeCardFromSlot(card)
                currentHand.addCard(card)
            } else {
                card.position = startPos
            }
        }
        
        card.zPosition = dragStartZPosition ?? 0
        dragStartZPosition = nil
        selectedCard = nil
        dragStartPosition = nil
        card.removeAction(forKey: "selectedSway")

    }
    
    //create a "battleSlot" for the card 
    func battleSlotUnderCard(_ card: Card) -> BattleSlot? {
        for slot in currentSlots {
            if slot.frame.intersects(card.frame) && !slot.isOccupied {
                return slot
            }
        }
        return nil
    }
    
    func canPlay(_ card: Card) -> Bool {
        let cardCost = card.pieceType.cost
        let currentPoints = currentPlayer == .player1 ? player1PlayedPoints : player2PlayedPoints
        
        
        if card.pieceType == .king || card.pieceType == .queen {
            let tracker = currentPlayer == .player1 ? p1TrackerView.pointTracker : p2TrackerView.pointTracker
            if !tracker.isUnlocked {
                return false
            }
        }
        
        
        return currentPoints >= cardCost
        
        
    }
    
    func removeCardFromSlot(_ card: Card) {
        guard let oldSlot = card.currentSlot else {return}
        if let slotIndex = currentSlots.firstIndex(of: oldSlot) {
            if currentPlayer == .player1 {
                player1PlacedCards[slotIndex] = nil
                let points = card.attack + card.defense
                p1TrackerView.pointTracker.addPoints(-points)
                player1PlayedPoints -= points
                p1TrackerView.updateBar()
            } else if currentPlayer == .player2 {
                    player2PlacedCards[slotIndex] = nil
                    let points = card.attack + card.defense
                p2TrackerView.pointTracker.addPoints(-points)
                player2PlayedPoints -= points
                p2TrackerView.updateBar()
                }
            }
            oldSlot.isOccupied = false
            card.currentSlot = nil
        }

    var combatOverlays: [SKShapeNode] = []

    func layoutForCombat() {
        let spacing: CGFloat = 200
        let totalWidth = spacing * 3
        let startX = size.width / 2 - totalWidth / 2
        let overlaySize = CGSize(width: 90, height: 130)

        for (i, card) in player1PlacedCards.enumerated() {
            guard let card = card else {continue}
            card.isHidden = false
            let target = CGPoint(x: startX + CGFloat(i) * spacing, y: size.height * 0.35)
            card.run(SKAction.move(to: target, duration: 0.5))

            // Card overlay
            let overlay = SKShapeNode(rectOf: overlaySize, cornerRadius: 8)
            overlay.fillColor = .red.withAlphaComponent(0.3)
            overlay.strokeColor = .red
            overlay.lineWidth = 2
            overlay.position = target
            overlay.zPosition = -0.5
            addChild(overlay)
            combatOverlays.append(overlay)
        }
        for (i, card) in player2PlacedCards.enumerated() {
            guard let card = card else {continue}
            card.isHidden = false
            let target = CGPoint(x: startX + CGFloat(i) * spacing, y: size.height * 0.65)
            card.run(SKAction.move(to: target, duration: 0.5))

            // Card overlay
            let overlay = SKShapeNode(rectOf: overlaySize, cornerRadius: 8)
            overlay.fillColor = .blue.withAlphaComponent(0.3)
            overlay.strokeColor = .blue
            overlay.lineWidth = 2
            overlay.position = target
            overlay.zPosition = -0.5
            addChild(overlay)
            combatOverlays.append(overlay)
        }

        // Move health bars to top/bottom horizontal during combat
        p1HBView.run(SKAction.group([
            SKAction.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.08), duration: 0.5),
            SKAction.rotate(toAngle: 0, duration: 0.5)
        ]))
        p1HBView.setCombatLayout()
        p2HBView.run(SKAction.group([
            SKAction.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.92), duration: 0.5),
            SKAction.rotate(toAngle: 0, duration: 0.5)
        ]))
        p2HBView.setCombatLayout()
    }
    
    func startCombatPhase() {
        print("Combat Phase")

        for card in player1Hand.cards { card.isHidden = true }
        for card in player2Hand.cards { card.isHidden = true }
        p1TrackerView.isHidden = true
        p2TrackerView.isHidden = true

        // Hide quantity labels
        for label in player1Hand.getLabelsToHand() {
            label.isHidden = true
        }
        for label in player2Hand.getLabelsToHand() {
            label.isHidden = true
        }

        // Hide ready button
        readyUp.isHidden = true

        // Hide slot outlines
        for slot in player1Slots { slot.isHidden = true }
        for slot in player2Slots { slot.isHidden = true }

        // Show both health bars for combat
        p1HBView.isHidden = false
        p2HBView.isHidden = false

        bgeffects.shouldEnableEffects = true
        layoutForCombat()
        
        
        //TODO: Position P1 and P2 cards
        //TODO: Animate Battle
        //TODO: Calculate damage
    }
    
    func playCombatSequence(results: [SlotResult]) {
        var actions: [SKAction] = []

        // Phase 1: All P1 cards attack
        for slot in results {
            let p1Card = slot.p1Card
            let p1Origin = p1Card.position
            let p1Attack = CombatAnimations.attackAnimation(for: p1Card, origin: p1Origin, direction: 1)

            let applyDmg = SKAction.run { [weak self] in
                self?.p2Health.reduceHP(slot.damageToP2)
                self?.p2HBView.updateBar()
                let pos = CGPoint(x: slot.p2Card.position.x, y: slot.p2Card.position.y + 100)
                self?.combatDisplay.showDamage(slot.damageToP2, position: pos, isPlayer1: false)
            }

            actions.append(SKAction.run { p1Card.run(p1Attack) })
            actions.append(SKAction.wait(forDuration: 0.3))
            actions.append(applyDmg)
            actions.append(SKAction.wait(forDuration: 0.6))
        }

        // Pause between P1 and P2 phases
        actions.append(SKAction.wait(forDuration: 0.8))

        // Phase 2: All P2 cards attack
        for slot in results {
            let p2Card = slot.p2Card
            let p2Origin = p2Card.position
            let p2Attack = CombatAnimations.attackAnimation(for: p2Card, origin: p2Origin, direction: -1)

            let applyDmg = SKAction.run { [weak self] in
                self?.p1Health.reduceHP(slot.damageToP1)
                self?.p1HBView.updateBar()
                let pos = CGPoint(x: slot.p1Card.position.x, y: slot.p1Card.position.y - 100)
                self?.combatDisplay.showDamage(slot.damageToP1, position: pos, isPlayer1: true)
            }

            actions.append(SKAction.run { p2Card.run(p2Attack) })
            actions.append(SKAction.wait(forDuration: 0.3))
            actions.append(applyDmg)
            actions.append(SKAction.wait(forDuration: 0.6))
        }

        // Phase 3: Apply all healing
        let applyHealing = SKAction.run { [weak self] in
            for slot in results {
                if slot.p1Healed > 0 {
                    self?.p1Health.heal(slot.p1Healed)
                    self?.p1HBView.updateBar()
                }
                if slot.p2Healed > 0 {
                    self?.p2Health.heal(slot.p2Healed)
                    self?.p2HBView.updateBar()
                }
            }
        }
        actions.append(applyHealing)
        actions.append(SKAction.wait(forDuration: 0.5))

        // Phase 4: Check for death AFTER both sides attacked
        let checkDeath = SKAction.run { [weak self] in
            if self?.p1Health.isDead == true {
                print("Player 1 has been defeated, Player 2 Wins")
            }
            if self?.p2Health.isDead == true {
                print("Player 2 has been defeated, Player 1 Wins")
            }
        }
        actions.append(checkDeath)
        actions.append(SKAction.wait(forDuration: 0.5))

        // Cleanup and resolve
        let finish = SKAction.run { [weak self] in
            self?.cleanUpAfterCombat()
            let p1Dmg = results.reduce(0) { $0 + $1.damageToP1 }
            let p2Dmg = results.reduce(0) { $0 + $1.damageToP2 }
            let combatResult = CombatResult(
                slotResults: results,
                player1DamageTaken: p1Dmg,
                player2DamageTaken: p2Dmg,
                player1CardsUsed: results.map { $0.p1Card },
                player2CardsUsed: results.map { $0.p2Card }
            )
            self?.turnManager.combatResolved(results: combatResult)
        }
        actions.append(finish)

        self.run(SKAction.sequence(actions))
    }
    
    func cleanUpAfterCombat() {

        for card in player1PlacedCards {
            card?.removeFromParent()
        }
        for card in player2PlacedCards {
            card?.removeFromParent()
        }
        player1PlacedCards = Array(repeating: nil, count: 4)
        player2PlacedCards = Array(repeating: nil, count: 4)

        for slot in player1Slots {
            slot.isOccupied = false
        }
        for slot in player2Slots {
            slot.isOccupied = false
        }

        // Remove combat overlays
        for overlay in combatOverlays {
            overlay.removeFromParent()
        }
        combatOverlays.removeAll()

        // Restore health bars to original vertical positions
        let slotSpacing: CGFloat = 160
        let totalWidth = slotSpacing * 3
        let startX = gameArea.midX - totalWidth / 2
        let endX = startX + totalWidth
        let healthBarOffset: CGFloat = 100
        p1HBView.run(SKAction.group([
            SKAction.move(to: CGPoint(x: startX - healthBarOffset, y: gameArea.midY - healthBarOffset), duration: 0.5),
            SKAction.rotate(toAngle: .pi / 2, duration: 0.5)
        ]))
        p1HBView.setNormalLayout()
        p2HBView.run(SKAction.group([
            SKAction.move(to: CGPoint(x: endX + healthBarOffset, y: gameArea.midY - healthBarOffset), duration: 0.5),
            SKAction.rotate(toAngle: .pi / 2, duration: 0.5)
        ]))
        p2HBView.setNormalLayout()

        // Show UI again after combat
        for label in player1Hand.getLabelsToHand() {
            label.isHidden = false
        }
        for label in player2Hand.getLabelsToHand() {
            label.isHidden = false
        }
        readyUp.isHidden = false
        bgeffects.shouldEnableEffects = false
    }

    func showRoundIndicator(round: Int) {
        // Create the round indicator sprite
        let roundIndicator = SKSpriteNode(imageNamed: "round\(round)")
        roundIndicator.position = CGPoint(x: size.width / 2, y: size.height / 2)
        roundIndicator.zPosition = 200 // Very high to appear above everything
        roundIndicator.alpha = 0
        roundIndicator.setScale(0.5)
        addChild(roundIndicator)

        // Animation sequence: fade in + scale up, hold, then fade out
        let fadeIn = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        let hold = SKAction.wait(forDuration: 1.4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([fadeIn, hold, fadeOut, remove])
        roundIndicator.run(sequence)
    }

}


extension GameScene: TurnManagerDelegate {
    func turnManager(_ manager: TurnManager, didSwitchTo player: Player) {
        //Hide old player's hand
        let newHand = (player == .player1) ? player1Hand : player2Hand
        let oldHand = (player == .player1) ? player2Hand: player1Hand
        let OldPlacedCards = (player == .player1) ? player2PlacedCards: player1PlacedCards
        
        for hand in oldHand!.cards {
            hand.isHidden = true
        }
        for card in OldPlacedCards {
            card?.isHidden = true
        }
        for card in newHand!.cards {
            card.isHidden = false
        }
        for slot in player1Slots { slot.isHidden = (player != .player1) }
        for slot in player2Slots { slot.isHidden = (player != .player2) }
        
        // Update slot colors for current player
        for slot in player1Slots {
            slot.strokeColor = .red
        }
        
        for slot in player2Slots {
            slot.strokeColor = .blue
        }
        
        // Toggle point tracker visibility
        p1TrackerView.isHidden = (player == .player2)
        p2TrackerView.isHidden = (player == .player1)

        // Toggle quantity labels
        for label in player1Hand.getLabelsToHand() {
            label.isHidden = (player == .player2)
        }
        for label in player2Hand.getLabelsToHand() {
            label.isHidden = (player == .player1)
        }

        // Health bars: own bar vertical on side, opponent's bar horizontal on opposite end
        let slotSpacing: CGFloat = 160
        let totalSlotWidth = slotSpacing * 3
        let slotStartX = gameArea.midX - totalSlotWidth / 2
        let slotEndX = slotStartX + totalSlotWidth
        let hbOffset: CGFloat = 100

        p1HBView.isHidden = false
        p2HBView.isHidden = false

        if player == .player1 {
            // P1's bar stays vertical on left side
            p1HBView.run(SKAction.group([
                SKAction.move(to: CGPoint(x: slotStartX - hbOffset, y: gameArea.midY - hbOffset), duration: 0.5),
                SKAction.rotate(toAngle: .pi / 2, duration: 0.5)
            ]))
            p1HBView.setNormalLayout()
            // P2's bar goes horizontal at top
            p2HBView.run(SKAction.group([
                SKAction.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.92), duration: 0.5),
                SKAction.rotate(toAngle: 0, duration: 0.5)
            ]))
            p2HBView.setCombatLayout()
        } else {
            // P2's bar stays vertical on right side
            p2HBView.run(SKAction.group([
                SKAction.move(to: CGPoint(x: slotEndX + hbOffset, y: gameArea.midY - hbOffset), duration: 0.5),
                SKAction.rotate(toAngle: .pi / 2, duration: 0.5)
            ]))
            p2HBView.setNormalLayout()
            // P1's bar goes horizontal at bottom
            p1HBView.run(SKAction.group([
                SKAction.move(to: CGPoint(x: size.width * 0.3, y: size.height * 0.08), duration: 0.5),
                SKAction.rotate(toAngle: 0, duration: 0.5)
            ]))
            p1HBView.setCombatLayout()
        }

        currentPlayer = player
        print("Now its \(currentPlayer)")
        
        turnBanner.showBanner(for: player)


    }
    
    func turnManagerDidStartCombat(_ manager: TurnManager) {
        //show all cards, start battle animation
        startCombatPhase()
        let combatResult = CombatResolver.resolve(p1Cards: player1PlacedCards, p2Cards: player2PlacedCards)
        //Wait for layoutForCombat animation
        self.run(SKAction.wait(forDuration: 0.6)) {[weak self] in
            self?.playCombatSequence(results: combatResult.slotResults)
        }
    }
    
    func turnManager(_ manager: TurnManager, didEnterPhase phase: TurnPhase) {
        //react to phase changes if needed
    }
    
    func turnManager(_ manager: TurnManager, didCompleteCombat results: CombatResult) {
        dealHand(for: .player1)
        dealHand(for: .player2)
    }

    func turnManager(_ manager: TurnManager, roundStart round: Int) {
        showRoundIndicator(round: round)
    }

}
