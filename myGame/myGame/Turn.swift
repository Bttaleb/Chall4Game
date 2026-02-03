//
//  Turn.swift
//  myGame
//
//  Created by Bassel Taleb on 1/27/26.
//
import SpriteKit
import Foundation

enum TurnPhase {
    case placing
    case combat
}

struct CombatResult {
    let player1DamageTaken: Int
    let player2DamageTaken: Int
    let player1CardsUsed: [Card]
    let player2CardsUsed: [Card]
}

protocol TurnManagerDelegate: AnyObject {
    func turnManager(_ manager: TurnManager, didSwitchTo player: Player)
    func turnManager(_ manager: TurnManager, didEnterPhase phase: TurnPhase)
    func turnManagerDidStartCombat(_ manager: TurnManager)
    func turnManager(_ manager: TurnManager, didCompleteCombat results: CombatResult)
}

class TurnManager {
    
    private(set) var currentPlayer: Player = .player1
    private(set) var currentPhase: TurnPhase = .placing
    private(set) var roundNumber: Int = 0
    private(set) var player1TurnCount: Int = 0
    private(set) var player2TurnCount: Int = 0
    
    weak var delegate: TurnManagerDelegate?
    
    let cardPerTurn: Int
    
    init(cardsPerTurn: Int = 4) {
        self.cardPerTurn = cardsPerTurn
    }
    
    func cardPlaced(totalFilledSlots: Int) {
        guard currentPhase == .placing else { return }
        if totalFilledSlots == cardPerTurn {
            handleTurnComplete()
        }
    }
    
    func handleTurnComplete() {
        if currentPlayer == .player1 {
            incrementTurnCount(for: .player1)
            switchToPlayer(.player2)
            print("Player 1's turn(s): \(player1TurnCount)")
        } else {
            incrementTurnCount(for: .player2)
            print("Player 2's turn(s): \(player2TurnCount)")
            print(roundNumber)
            startCombat()
        }
    }
    
    private func incrementTurnCount(for player: Player) {
        switch player {
        case .player1: player1TurnCount += 1
        case .player2: player2TurnCount += 1
        }
    }
    
    private func switchToPlayer(_ player: Player) {
        currentPlayer = player
        currentPhase = .placing
        delegate?.turnManager(self, didSwitchTo: player)
        delegate?.turnManager(self, didEnterPhase: .placing)
    }
    
    private func startCombat() {
        currentPhase = .combat
        delegate?.turnManager(self, didEnterPhase: .combat)
        delegate?.turnManagerDidStartCombat(self)
    }
    
    private func incrementRound() {
        roundNumber += 1
    }
    
    func combatResolved(results: CombatResult) {
        delegate?.turnManager(self, didCompleteCombat: results)
        currentPlayer = .player1
        currentPhase = .placing
        delegate?.turnManager(self, didSwitchTo: .player1)
        incrementRound()
    }
}
