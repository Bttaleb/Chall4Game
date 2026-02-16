import SpriteKit

class OnboardingOverlay {
    weak var scene: SKScene?
    var onDismiss: (() -> Void)?

    private let containerNode = SKNode()
    private var currentPage = 0

    private let pages: [(title: String, body: String)] = [
        ("How to Play",
         "Drag cards from your hand into\nthe 4 battle slots.\n\nTap a card to flip it and\nsee its stats.\n\nFill all 4 slots, then hit Ready."),

        ("Card Types",
         "Pawn — 5 ATK\nKnight — 10 ATK, Pierce\nBishop — Shield 25%\nRook — Shield 50%\nQueen — 25 ATK, Lifesteal\nKing — Shield 75%"),

        ("Power System",
         "Placing cards fills your Power bar.\n\nOnce it hits 60, King and Queen\nunlock and can be played.\n\nPower carries over to the next round."),

        ("Abilities",
         "Pierce — Ignores enemy defense.\n\nShield — Reduces incoming damage\nby a percentage.\n\nLifesteal — Heals you for half\nthe damage dealt."),

        ("Combat",
         "Each slot fights the opposing slot\nsimultaneously.\n\nBoth players attack at the same time.\n\nReduce your opponent to 0 HP to win!")
    ]

    init(scene: SKScene) {
        self.scene = scene
    }

    func show() {
        guard let scene = scene else { return }
        containerNode.zPosition = 300
        scene.addChild(containerNode)
        buildPage()
    }

    func dismiss() {
        containerNode.removeFromParent()
        onDismiss?()
    }

    func handleTap(at location: CGPoint) {
        guard let scene = scene else { return }
        let tapped = scene.atPoint(location)

        switch tapped.name {
        case "onboardingNext":
            nextPage()
        case "onboardingBack":
            prevPage()
        case "onboardingClose", "onboardingBG":
            dismiss()
        default:
            // Also check parent name (for label inside button)
            if tapped.parent?.name == "onboardingNext" {
                nextPage()
            } else if tapped.parent?.name == "onboardingBack" {
                prevPage()
            } else if tapped.parent?.name == "onboardingClose" {
                dismiss()
            }
        }
    }

    // MARK: - Navigation

    private func nextPage() {
        guard currentPage < pages.count - 1 else { return }
        currentPage += 1
        buildPage()
    }

    private func prevPage() {
        guard currentPage > 0 else { return }
        currentPage -= 1
        buildPage()
    }

    // MARK: - Rendering

    private func buildPage() {
        guard let scene = scene else { return }
        containerNode.removeAllChildren()

        let sceneSize = scene.size
        let centerX = sceneSize.width / 2
        let centerY = sceneSize.height / 2

        // Dimmed background
        let bg = SKShapeNode(rectOf: sceneSize)
        bg.fillColor = .black
        bg.alpha = 0.7
        bg.strokeColor = .clear
        bg.position = CGPoint(x: centerX, y: centerY)
        bg.name = "onboardingBG"
        bg.zPosition = 0
        containerNode.addChild(bg)

        // Content panel
        let panelW = sceneSize.width * 0.7
        let panelH = sceneSize.height * 0.5
        let panel = SKShapeNode(rectOf: CGSize(width: panelW, height: panelH), cornerRadius: 20)
        panel.fillColor = UIColor(white: 0.12, alpha: 0.95)
        panel.strokeColor = UIColor(white: 0.4, alpha: 1.0)
        panel.lineWidth = 2
        panel.position = CGPoint(x: centerX, y: centerY)
        panel.zPosition = 1
        containerNode.addChild(panel)

        let page = pages[currentPage]

        // Title
        let title = SKLabelNode(text: page.title)
        title.fontName = "ChineseRocksRg-Regular"
        title.fontSize = 38
        title.fontColor = .white
        title.position = CGPoint(x: centerX, y: centerY + panelH / 2 - 55)
        title.zPosition = 2
        containerNode.addChild(title)

        // Body text
        let body = SKLabelNode()
        body.text = page.body
        body.fontName = "ChineseRocksRg-Regular"
        body.fontSize = 22
        body.fontColor = UIColor(white: 0.85, alpha: 1.0)
        body.numberOfLines = 0
        body.preferredMaxLayoutWidth = panelW - 60
        body.verticalAlignmentMode = .center
        body.horizontalAlignmentMode = .center
        body.position = CGPoint(x: centerX, y: centerY + 10)
        body.zPosition = 2
        containerNode.addChild(body)

        // Page dots
        let dotSpacing: CGFloat = 18
        let totalDotsWidth = dotSpacing * CGFloat(pages.count - 1)
        let dotsStartX = centerX - totalDotsWidth / 2
        let dotsY = centerY - panelH / 2 + 50

        for i in 0..<pages.count {
            let dot = SKShapeNode(circleOfRadius: i == currentPage ? 6 : 4)
            dot.fillColor = i == currentPage ? .white : UIColor(white: 0.5, alpha: 1.0)
            dot.strokeColor = .clear
            dot.position = CGPoint(x: dotsStartX + CGFloat(i) * dotSpacing, y: dotsY)
            dot.zPosition = 2
            containerNode.addChild(dot)
        }

        // Navigation buttons
        let buttonY = dotsY - 35

        if currentPage > 0 {
            let back = SKLabelNode(text: "< Back")
            back.fontName = "ChineseRocksRg-Regular"
            back.fontSize = 24
            back.fontColor = UIColor(white: 0.7, alpha: 1.0)
            back.name = "onboardingBack"
            back.position = CGPoint(x: centerX - panelW / 2 + 60, y: buttonY)
            back.zPosition = 2
            containerNode.addChild(back)
        }

        if currentPage < pages.count - 1 {
            let next = SKLabelNode(text: "Next >")
            next.fontName = "ChineseRocksRg-Regular"
            next.fontSize = 24
            next.fontColor = .white
            next.name = "onboardingNext"
            next.position = CGPoint(x: centerX + panelW / 2 - 60, y: buttonY)
            next.zPosition = 2
            containerNode.addChild(next)
        } else {
            let done = SKLabelNode(text: "Got it!")
            done.fontName = "ChineseRocksRg-Regular"
            done.fontSize = 24
            done.fontColor = .white
            done.name = "onboardingClose"
            done.position = CGPoint(x: centerX + panelW / 2 - 60, y: buttonY)
            done.zPosition = 2
            containerNode.addChild(done)
        }

        // Close X button (top-right of panel)
        let closeX = SKLabelNode(text: "X")
        closeX.fontName = "ChineseRocksRg-Regular"
        closeX.fontSize = 26
        closeX.fontColor = UIColor(white: 0.6, alpha: 1.0)
        closeX.name = "onboardingClose"
        closeX.position = CGPoint(x: centerX + panelW / 2 - 30, y: centerY + panelH / 2 - 35)
        closeX.zPosition = 2
        containerNode.addChild(closeX)
    }
}
