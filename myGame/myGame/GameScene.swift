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
    var player1PlacedCards: [Card] = []
    var player2PlacedCards: [Card] = []
    var currentPlacedCards: [Card] {
        return currentPlayer == .player1 ? player1PlacedCards : player2PlacedCards
    }
    
    var selectedCard: Card?
    var dragStartPosition: CGPoint?
    var dragStartZPosition: CGFloat?
    //Store reference to battle slots -> into arrays (multiple slots)
    var battleSlots: [BattleSlot] = []
    var player1Hand: Hand!
    var player2Hand: Hand!
    var gameTurns: Int = 0
    var player1Turn: Int = 0
    var player2Turn: Int = 0
    
    //store ref to point trackers
    var p1TrackerView: PointTrackerView!
    var p2TrackerView: PointTrackerView!
    
    
    let card: Card?
    let gameArea: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y:0, width: playableWidth, height: size.height)
        
        card = nil
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    
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
            card.setScale(2)
            if player == .player2 {
                card.isHidden = true
            }
            addChild(card)
            hand?.addCard(card)
        }
    }
    
    override func didMove(to view: SKView) {
        turnManager = TurnManager(cardsPerTurn: 4)
        turnManager.delegate = self
        
        let slotSize = CGSize(width: 80, height: 120)
        let slotSpacing: CGFloat = 200
        let totalWidth = slotSpacing * 3
        let startX = gameArea.midX - totalWidth / 2
        
        //make player1's slot
        for i in 0..<4 {
            let slot = BattleSlot(size: slotSize, owner: .player1)
            slot.position = CGPoint(
                x: startX + CGFloat(i) * slotSpacing,
                y: gameArea.midY
            )
            addChild(slot)
            battleSlots.append(slot)
        }
        
//health bar displays
        p1Health = HealthBar(maxHP: 100)
        p1HBView = HealthbarView(healthBar: p1Health, width: size.width * 0.4)
        p1HBView.position = CGPoint(x: 20, y: size.height * 0.15 + 40)
        addChild(p1HBView)

        p2Health = HealthBar(maxHP: 100)
        p2HBView = HealthbarView(healthBar: p2Health, width: size.width * 0.4)
        p2HBView.position = CGPoint(x: 20, y: size.height * 0.85 + 60)
        addChild(p2HBView)

        //King and queen point tracker
        let p1Tracker = PointTracker()
        p1TrackerView = PointTrackerView(pointTracker: p1Tracker, width: size.width * 0.2)
        p1TrackerView.position = CGPoint(x: 20, y: size.height * 0.15 + 70)
        addChild(p1TrackerView)

        let p2Tracker = PointTracker()
        p2TrackerView = PointTrackerView(pointTracker: p2Tracker, width: size.width * 0.2)
        p2TrackerView.position = CGPoint(x: 20, y: size.height * 0.85 + 90)
        addChild(p2TrackerView)
        
        player1Hand = Hand(position: CGPoint(x: gameArea.midX, y: gameArea.height * 0.15))
        player2Hand = Hand(position: CGPoint(x: gameArea.midX, y: gameArea.height * 0.85))
        
        player1Deck = DeckBuilder.standardDeck()
        player2Deck = DeckBuilder.standardDeck()
        
        dealHand(for: .player1)
        dealHand(for: .player2)
    }
    
    // "Began" fires when finger first touches screen, use nodes(at:) to find WHAT is under touch point
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        
        let dx = card.position.x - startPos.x
        let dy = card.position.y - startPos.y
        let distance = sqrt(dx * dx + dy * dy)
        
        //flip if a tap
        if distance < 10 {
            card.flip()
        } else { //append
            if let oldSlot = card.currentSlot {
                oldSlot.isOccupied = false
                card.currentSlot = nil
            }
            
            
            if let newSlot = battleSlotUnderCard(card) {
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
                    player1PlacedCards.append(card)
                    //adds points to p1 point tracker
                    let points = card.attack + card.defense
                    p1TrackerView.pointTracker.addPoints(points)
                    player1PlayedPoints += points
                    p1TrackerView.updateBar()
                    print("\(currentPlayer) placed: \(card.pieceType.name) w/ ATK \(card.attack), DEF \(card.defense), current played points: \(player1PlayedPoints)")
                } else {
                    currentPlayer = .player2
                    player2PlacedCards.append(card)
                    //add points to p2 point tracker
                    let points = card.attack + card.defense
                    p2TrackerView.pointTracker.addPoints(points)
                    player2PlayedPoints += points
                    p2TrackerView.updateBar()
                    print("\(currentPlayer) placed: \(card.pieceType.name) w/ ATK \(card.attack), DEF \(card.defense)")
                }
                
                let filledCount = battleSlots.filter { $0.isOccupied } .count
                turnManager.cardPlaced(totalFilledSlots: filledCount)
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
        for slot in battleSlots {
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
    
    func startCombatPhase() {
        print("Combat Phase")
        
        for card in player1PlacedCards {
            card.isHidden = false
        }
        for card in player2PlacedCards {
            card.isHidden = false
        }
        
        //TODO: Position P1 and P2 cards
        //TODO: Animate Battle
        //TODO: Calculate damage
    }
    
    func cleanUpAfterCombat() {
        for card in player1PlacedCards + player2PlacedCards {
            card.removeFromParent()
        }
        player1PlacedCards.removeAll()
        player2PlacedCards.removeAll()
        for slot in battleSlots {
            slot.isOccupied = false
        }
    }

}


extension GameScene: TurnManagerDelegate {
    func turnManager(_ manager: TurnManager, didSwitchTo player: Player) {
        //Hide old player's hand
        let newHand = (player == .player1) ? player1Hand : player2Hand
        let OldPlacedCards = (player == .player1) ? player2PlacedCards: player1PlacedCards
        
        for card in OldPlacedCards {
            card.isHidden = true
        }
        for card in newHand!.cards {
            card.isHidden = false
        }
        for spot in battleSlots {
            spot.isOccupied = false
        }
        for slot in battleSlots {
            slot.strokeColor = player == .player1 ? .blue : .red
        }
        
        currentPlayer = player
        print("Now its \(currentPlayer)")

        
    }
    func turnManagerDidStartCombat(_ manager: TurnManager) {
        //show all cards, start battle animation
        startCombatPhase()
        let combatResult = CombatResolver.resolve(p1Cards: player1PlacedCards, p2Cards: player2PlacedCards, p1Health: p1Health, p2Health: p2Health)
        p1HBView.updateBar()
        p2HBView.updateBar()
        
        if p1Health.isDead {
            print("Player 1 has been defeated, Player 2 wins")
        }
        if p2Health.isDead {
            print("Player 2 has been defeated, Player 1 wins")
        }
        
        cleanUpAfterCombat()
        turnManager.combatResolved(results: combatResult)
    }
    func turnManager(_ manager: TurnManager, didEnterPhase phase: TurnPhase) {
        //react to phase changes if needed
    }
    func turnManager(_ manager: TurnManager, didCompleteCombat results: CombatResult) {
        dealHand(for: .player1)
        dealHand(for: .player2)
    }
}
