import SpriteKit

enum Ability {
    case pierce
    case lifesteal
    case doublestrike
    case shield
}

// Card Identity
enum PieceType: CaseIterable {
    case pawn, knight, bishop, rook, queen, king
    var name: String {
        switch self {
        case .pawn: return "pawn"
        case .knight: return "knight"
        case .bishop: return "bishop"
        case .rook: return "rook"
        case .queen: return "queen"
        case .king: return "king"
        }
    }
    
    // Extract piece from png file
    var imageName: String {
        switch self {
        case .pawn: return "pawn-piece"
        case .knight: return "knight-piece"
        case .bishop: return "bishop-piece"
        case .rook: return "rook-piece"
        case .queen: return "queen-piece"
        case .king: return "king-piece"
        }
    }
    
    var backImageName: String {
        switch self {
        case .pawn: return "pawn-back"
        case .knight: return "knight-back"
        case .bishop: return "bishop-back"
        case .rook: return "rook-back"
        case .queen: return "queen-back"
        case .king: return "king-back"        }
    }
    var cost: Int {
        switch self {
        case .pawn: return 0
        case .knight: return 0
        case .bishop: return 0
        case .rook: return 0
        case .queen: return 0
        case .king: return 0 //TBD
        }
    }
    
    var baseStats: (attack: Int, defense: Int, abilities: Set<Ability>) {
        switch self {
        case .pawn: return (5, 0, [])
        case .knight: return (10, 0, [.pierce])
        case .bishop: return (0, 0, [.shield])
        case .rook: return (0, 0, [.shield])
        case .queen: return (25, 0, [.lifesteal])
        case .king: return (0, 0, [.shield])
        }
    }

    // Shield strength: how much damage is blocked (0.0 to 1.0)
    var shieldStrength: Double {
        switch self {
        case .bishop: return 0.25
        case .rook: return 0.50
        case .king: return 0.75
        default: return 0.0
        }
    }

}

// CardLayer - Rendering Data (does NOT know about rook/knight/etc)
// only describes "draw these assets here"
struct CardLayer: Codable {
    let imageName: String
    let zPosition: CGFloat
    var offset: CGPoint
    
    init(_ imageName: String, z: CGFloat, offset: CGPoint = .zero) {
        self.imageName = imageName
        self.zPosition = z
        self.offset = offset
    }
}

enum Player {
    case player1
    case player2
}

// Owns config. layer
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
    var lockOverlay: SKLabelNode?
    
    //initialize let properties BEFORE super.init
    init(data: CardData) {
        self.backTexture = SKTexture(imageNamed: data.pieceType.backImageName)
        self.pieceType = data.pieceType
        self.frontTexture = Card.renderFrontTexture(for: data.pieceType)

        //call super.init -> SKSpriteNode sets itself up with the full card texture
        super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
        
        //after super.init -> self is ready 0-> data pulled from cardData
        self.setScale(0.3)
        self.attack = data.attack
        self.defense = data.defense
        self.abilities = data.abilities
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Animations
    
    //king and queen locked
    func applyLock() {
        self.color = .gray
        self.colorBlendFactor = 0.7
        
        let lock = SKLabelNode(text: "X")
        // add custom image later
        lock.fontSize = 150
        lock.position = CGPoint(x:0, y:0)
        lock.zPosition = 10
        addChild(lock)
        lockOverlay = lock
    }
    
    func removeLock() {
        self.colorBlendFactor = 0
        lockOverlay?.removeFromParent()
        lockOverlay = nil
    }
    
    
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
        
        //king and queen locked func
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
    
    static func renderFrontTexture(for pieceType: PieceType) -> SKTexture {
        return SKTexture(imageNamed: "\(pieceType.name)-card")
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs === rhs
    }
}


