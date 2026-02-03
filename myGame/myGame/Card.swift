import SpriteKit

enum Ability {
    case pierce
    case lifesteal
    case doublestrike
    case shield
}

enum PieceType: CaseIterable {
    case pawn, knight, bishop, rook, queen, king
    var name: String {
        switch self {
        case .pawn: return "Pawn"
        case .knight: return "Knight"
        case .bishop: return "Bishop"
        case .rook: return "Rook"
        case .queen: return "Queen"
        case .king: return "King"
        }
    }
    var imageName: String {
        switch self {
        case .pawn: return "white-pawn"
        case .knight: return "white-knight"
        case .bishop: return "white-bishop"
        case .rook: return "white-rook"
        case .queen: return "white-queen"
        case .king: return "white-king"
        }
    }
    
    var cost: Int {
        switch self {
        case .pawn: return 0
        case .knight: return 3
        case .bishop: return 3
        case .rook: return 5
        case .queen: return 9
        case .king: return 0 //TBD
        }
    }
    
    var baseStats: (attack: Int, defense: Int, abilities: Set<Ability>) {
        switch self {
        case .pawn: return (5, 0, [])
        case .knight: return (10, 5, [.pierce])
        case .bishop: return (5, 10, [.doublestrike])
        case .rook: return (0, 5, [.shield])
        case .queen: return (25, 25, [.lifesteal, .pierce, .doublestrike])
        case .king: return (25, 25, [.shield])
        }
    }
}

enum Player {
    case player1
    case player2
}

struct GameState {
    var player1HP: Int = 20
    var player2HP: Int = 20
    
    mutating func dealDamage(to player: Player, amount: Int) {
        switch player {
        case .player1: player1HP = max(0, player1HP - amount)
        case .player2: player2HP = max(0, player2HP - amount)
        }
    }
    
    func isGameOver() -> Bool {
        return player1HP <= 0 || player2HP <= 0
    }
    
}

class Card: SKSpriteNode {
    // MARK: Properties
    let frontTexture: SKTexture
    let backTexture: SKTexture
    var attack: Int = 0
    var defense: Int = 0
    var abilities: Set<Ability> = []
    var isFaceUp: Bool = true
    var currentSlot: BattleSlot?
    let pieceType: PieceType
    
    //initialize let properties BEFORE super.init
    init(data: CardData, backImage: String) {
        self.backTexture = SKTexture(imageNamed: backImage)
        self.pieceType = data.pieceType
        self.frontTexture = SKTexture(imageNamed: data.pieceType.imageName)
        
        //call super.init -> SKSpriteNode sets itself up
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
        
        //after super.init -> self is ready 0-> data pulled from cardData
        self.attack = data.attack
        self.defense = data.defense
        self.abilities = data.abilities

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Animations
    func flip() {
        
        guard action(forKey: "flip") == nil else { return }
        
        let originalScaleX = self.xScale
        
        let firstHalf = SKAction.scaleX(to: 0, duration: 0.15)
        firstHalf.timingMode = .easeIn
        
        let swapTexture = SKAction.run { [weak self] in
            guard let self = self else { return }
            self.isFaceUp.toggle()
            self.texture = self.isFaceUp ? self.frontTexture : self.backTexture
        }
        
        let secondHalf = SKAction.scaleX(to: originalScaleX, duration: 0.15)
        secondHalf.timingMode = .easeOut
        
        let flipSequence = SKAction.sequence([firstHalf, swapTexture, secondHalf])
        run(flipSequence, withKey: "flip")
    }
    
    func addFloatyAnimation() {
        
        let swayRight = SKAction.rotate(byAngle: 0.02, duration: 1.0)
        swayRight.timingMode = .easeInEaseOut
        let swayLeft = SKAction.rotate(byAngle: -0.02, duration: 1.0)
        swayLeft.timingMode = .easeInEaseOut
        let rotationSway = SKAction.sequence([swayLeft, swayRight])
        
        let nudgeRight = SKAction.moveBy(x: 4, y: 0, duration: 0.8)
        nudgeRight.timingMode = .easeInEaseOut
        let nudgeLeft = SKAction.moveBy(x: -4, y: 0, duration: 0.8)
        nudgeLeft.timingMode = .easeInEaseOut
        let horizontalSway = SKAction.sequence([nudgeRight, nudgeLeft])
        
        let combined = SKAction.group([rotationSway, horizontalSway])
        run(SKAction.repeatForever(combined), withKey: "selectedSway")
    }
    
}

func ==(lhs: Card, rhs: Card) -> Bool {
    return lhs === rhs
}
