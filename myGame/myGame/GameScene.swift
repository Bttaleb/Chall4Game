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
    var player1Hand: Hand!
    var player2Hand: Hand!
    var gameTurns: Int = 0
    var player1Turn: Int = 0
    var player2Turn: Int = 0
    
    
    //displays combat numbers
    var combatDisplay: CombatDisplay!
    
    //store ref to point trackers
    var p1TrackerView: PointTrackerView!
    var p2TrackerView: PointTrackerView!
    
    
    let card: Card?
    var gameArea: CGRect
    
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
            let card = Card(data: cardData, backImage: "card_back")
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
        addChild(bg)
        
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
        p1HBView = HealthbarView(healthBar: p1Health, width: size.width * 0.4)
        addChild(p1HBView)

        p2Health = HealthBar(maxHP: 50)
        p2HBView = HealthbarView(healthBar: p2Health, width: size.width * 0.4)
        addChild(p2HBView)

        // Point trackers
        let p1Tracker = PointTracker()
        p1TrackerView = PointTrackerView(pointTracker: p1Tracker, width: size.width * 0.2)
        addChild(p1TrackerView)

        let p2Tracker = PointTracker()
        p2TrackerView = PointTrackerView(pointTracker: p2Tracker, width: size.width * 0.2)
        addChild(p2TrackerView)
        
        //combat displays
        combatDisplay = CombatDisplay(scene: self)
        
        player1Hand = Hand(position: .zero)
        player2Hand = Hand(position: .zero)
        
        player1Deck = DeckBuilder.standardDeck()
        player2Deck = DeckBuilder.standardDeck()
        
        layoutUI()
        
        dealHand(for: .player1)
        dealHand(for: .player2)
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
        let slotSpacing: CGFloat = 200
        let totalWidth = slotSpacing * 3
        let startX = gameArea.midX - totalWidth / 2
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
        p1HBView?.position = CGPoint(x: 20, y: size.height * 0.15 + 140)
        p2HBView?.position = CGPoint(x: 20, y: size.height * 0.85 + 120)
        
        // Point trackers
        p1TrackerView?.position = CGPoint(x: 20, y: size.height * 0.15 + 180)
        p2TrackerView?.position = CGPoint(x: 20, y: size.height * 0.85 + 160)
        
        // Hands
        player1Hand?.position = CGPoint(x: gameArea.midX, y: size.height * 0.15)
        player1Hand?.layoutCards()
        player2Hand?.position = CGPoint(x: gameArea.midX, y: size.height * 0.85)
        player2Hand?.layoutCards()
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
                }
                
                let filledCount = currentSlots.filter { $0.isOccupied } .count
                turnManager.cardPlaced(totalFilledSlots: filledCount)
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
        return currentPoints >= cardCost
    }
    
    func removeCardFromSlot(_ card: Card) {
        guard let oldSlot = card.currentSlot else {return}
        if let slotIndex = currentSlots.firstIndex(of: oldSlot) {
            if currentPlayer == .player1 {
                player1PlacedCards[slotIndex] = nil
            } else if currentPlayer == .player2 {
                player2PlacedCards[slotIndex] = nil
            }
        }
            oldSlot.isOccupied = false
            card.currentSlot = nil
        
        }
    
    func layoutForCombat() {
        let spacing: CGFloat = 200
        let totalWidth = spacing * 3
        let startX = size.width / 2 - totalWidth / 2
        
        for (i, card) in player1PlacedCards.enumerated() {
            guard let card = card else {continue}
            card.isHidden = false
            let target = CGPoint(x: startX + CGFloat(i) * spacing, y: size.height * 0.4)
            card.run(SKAction.move(to: target, duration: 0.5))
        }
        for (i, card) in player2PlacedCards.enumerated() {
            guard let card = card else {continue}
            card.isHidden = false
            let target = CGPoint(x: startX + CGFloat(i) * spacing, y: size.height * 0.6)
            card.run(SKAction.move(to: target, duration: 0.5))
        }
    }
    
    func startCombatPhase() {
        print("Combat Phase")
        
        for card in player1Hand.cards { card.isHidden = true }
        for card in player2Hand.cards { card.isHidden = true }
        layoutForCombat()
        
        
        //TODO: Position P1 and P2 cards
        //TODO: Animate Battle
        //TODO: Calculate damage
    }
    
    func playCombatSequence(results: [SlotResult], index: Int) {
        //Base case, all slots resolved
        guard index < results.count else {
            //Combat over, check health
            if p1Health.isDead {
                print("Player 1 has been defeated, Player 2 Wins")
            }
            if p2Health.isDead {
                print("Player 2 has been defeated, Player 1 Wins")
            }
            cleanUpAfterCombat()
            turnManager.combatResolved(results: CombatResult(
                slotResults: results,
                player1DamageTaken: results.reduce(0) { $0 + $1.damageToP1 },
                player2DamageTaken: results.reduce(0) { $0 + $1.damageToP2 },
                player1CardsUsed: results.map { $0.p1Card },
                player2CardsUsed: results.map { $0.p2Card }
            ))
            return
        }
        
        let slot = results[index]
        let p1Card = slot.p1Card
        let p2Card = slot.p2Card
        
        //Save original pos.
        let p1Origin = p1Card.position
        let p2Origin = p2Card.position
        
        //Attack anim.
        let p1Lunge = SKAction.moveBy(x: 0, y: 60, duration: 0.15)
        let p1Return = SKAction.move(to: p1Origin, duration: 0.15)
        let applyP1Dmg = SKAction.run {[weak self] in
            self?.p2Health.reduceHP(slot.damageToP2)
            self?.p2HBView.updateBar()
            //combat display positioning
            let pos = CGPoint(x: p2Card.position.x, y: p2Card.position.y + 100 )
            self?.combatDisplay.showDamage(slot.damageToP2, position: pos, isPlayer1: false)
        }
        
        let p2Lunge = SKAction.moveBy(x: 0, y: -60, duration: 0.15)
        let p2Return = SKAction.move(to: p2Origin, duration: 0.15)
        let applyP2Dmg = SKAction.run {[weak self] in
            self?.p1Health.reduceHP(slot.damageToP1)
            self?.p1HBView.updateBar()
            //combat display positioning
            let pos = CGPoint(x: p1Card.position.x, y: p1Card.position.y-100)
            self?.combatDisplay.showDamage(slot.damageToP1, position: pos, isPlayer1: true)
        }
        
        let applyHealing = SKAction.run {[weak self] in
            if slot.p1Healed > 0 {
                self?.p1Health.heal(slot.p1Healed)
                self?.p1HBView.updateBar()
            }
            if slot.p2Healed > 0 {
                self?.p2Health.heal(slot.p2Healed)
                self?.p2HBView.updateBar()
            }
        }
        let pause = SKAction.wait(forDuration: 0.5)
        
        // Build the full sequence for this slot
        let p1Attack = SKAction.sequence([p1Lunge, p1Return])
        
        let p2Attack = SKAction.sequence([p2Lunge, p2Return])
        
        let fullSequence = SKAction.sequence([
            // P1 attacks
            SKAction.run { p1Card.run(p1Attack) },
            applyP1Dmg,
            SKAction.wait(forDuration: 0.35),
            // P2 attacks
            SKAction.run { p2Card.run(p2Attack) },
            applyP2Dmg,
            SKAction.wait(forDuration: 0.35),
            // Healing
            applyHealing,
            pause
        ])
        
        self.run(fullSequence) { [weak self] in
            self?.playCombatSequence(results: results, index: index + 1)
        }
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
        let currentSlots = (player == .player1) ? player1Slots : player2Slots
        for slot in currentSlots {
            slot.strokeColor = player == .player1 ? .blue : .red
        }
        
        currentPlayer = player
        print("Now its \(currentPlayer)")

        
    }
    func turnManagerDidStartCombat(_ manager: TurnManager) {
        //show all cards, start battle animation
        startCombatPhase()
        let combatResult = CombatResolver.resolve(p1Cards: player1PlacedCards, p2Cards: player2PlacedCards)
        //Wait for layoutForCombat animation
        self.run(SKAction.wait(forDuration: 0.6)) {[weak self] in
            self?.playCombatSequence(results: combatResult.slotResults, index: 0)
        }
    }
    func turnManager(_ manager: TurnManager, didEnterPhase phase: TurnPhase) {
        //react to phase changes if needed
    }
    func turnManager(_ manager: TurnManager, didCompleteCombat results: CombatResult) {
        dealHand(for: .player1)
        dealHand(for: .player2)
    }
}
