//
//  GameScene.swift
//  SetGame
//
//  Created by Hadi Sharghi on 3/26/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import SpriteKit
import GameplayKit
import SetGameEngine

class GameCard: SKSpriteNode {
    
    private let selectionScale: CGFloat = 1.15
    var card: Card
    var isSelected: Bool = false {
        didSet {
            setSelected(selected: isSelected)
        }
    }
    
    init(card: Card, initialScale: CGFloat = 1) {
        self.card = card
        let bgtexture = SKTexture(imageNamed: "card")
        super.init(texture: bgtexture, color: SKColor.clear, size: bgtexture.size())
        
        self.size = CGSize(width: self.size.width * initialScale, height: self.size.height * initialScale)
        var icons: [SKSpriteNode]
        let shader = GameCard.createColorNonAlpha(color: GameCard.getCardColor(card: card))
        icons = (1...card.count).map { _ in SKSpriteNode(texture: SKTexture(imageNamed: GameCard.getFileName(for: card))) }
        icons.forEach { icon in
            icon.shader = shader
            icon.name = "card"
            icon.size = CGSize(width: icon.size.width * initialScale, height: icon.size.height * initialScale)
        }
        switch card.count {
        case 1:
            if let icon = icons.first {
                icon.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(icon)
            }
        case 2:
            let icon1 = icons[0]
            let icon2 = icons[1]
            icon1.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 0.75 * icon1.size.height)
            icon2.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 0.75 * icon1.size.height)
            self.addChild(icon1)
            self.addChild(icon2)
            
        case 3:
            let icon1 = icons[0]
            let icon2 = icons[1]
            let icon3 = icons[2]
            icon1.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            icon2.position = CGPoint(x: self.frame.midX, y: self.frame.midY + 1.5 * icon1.size.height)
            icon3.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 1.5 * icon1.size.height)
            self.addChild(icon1)
            self.addChild(icon2)
            self.addChild(icon3)
            
        default: print("eybaba \(card.count)")
        }
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func createColorNonAlpha(color: SKColor) -> SKShader {
        let uniforms: [SKUniform] = [
            SKUniform(name: "u_color", color: color)
        ]
        
        return SKShader(fromFile: "SHKColorNonAlpha", uniforms: uniforms)
    }
    
    static func getFileName(for card: Card) -> String {
        var name = ""
        switch card.shape {
        case .capsule:
            name = "capsule"
        case .eyebrow:
            name = "eyebrow"
        case .rhombus:
            name = "rhombus"
        }
        
        name += "-"
        
        switch card.fill {
        case .empty:
            name += "empty"
        case .hatch:
            name += "hatch"
        case .solid:
            name += "solid"
        }
        
        return name
    }
    
    static func getCardColor(card: Card) -> SKColor {
        switch card.color {
        case .blue:
            return .blue
        case .green:
            return .green
        case .red:
            return .red
        }
    }
    
    private func setSelected(selected: Bool) {
        if selected {
            self.zPosition = 100
            self.fadeTexture(to: SKTexture(imageNamed: "shadow"), duration: 0.2)
            self.run(SKAction.scale(to: selectionScale, duration: 0.2))
        } else {
            self.zPosition = 0
            self.fadeTexture(to: SKTexture(imageNamed: "card"), duration: 0.2)
            self.run(SKAction.scale(to: 1, duration: 0.2))
        }
    }
    
    func fadeTexture(newTexture: SKTexture, onto spriteNode: SKSpriteNode, duration: CFTimeInterval) {
        let fadeInSpriteNode = fadeInSprite(with: newTexture, spriteNode: spriteNode)
        spriteNode.parent?.addChild(fadeInSpriteNode)
        fadeInSpriteNode.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1, duration: duration),
            SKAction.run {
                fadeInSpriteNode.removeFromParent()
                spriteNode.texture = newTexture
            }
        ]))
    }
    
    func fadeInSprite(with texture: SKTexture, spriteNode: SKSpriteNode) -> SKSpriteNode {
        let fadeInSprite = SKSpriteNode(texture: texture, size: spriteNode.size)
        fadeInSprite.alpha = 0
        fadeInSprite.anchorPoint = spriteNode.anchorPoint
        fadeInSprite.position = spriteNode.position
        
        return fadeInSprite
    }
}


class GameScene: SKScene {
    
    typealias Board = [[GameCard?]]
    
    var game = Engine(players: 1)
    var cards = [Card]()
    var board = Board()
    var selectedCards = Set<GameCard>()
    let cardSpacing: CGFloat = 5
    
    var boardWidth: CGFloat = 0
    var boardHeight: CGFloat = 0
    
    let columns = 4
    let rows = 3
    
    override func didMove(to view: SKView) {
        
        board = Board(repeating: [GameCard?](repeating: nil, count: columns + 1), count: rows)
        
        cards = game.draw()
        fillBoard(with: cards)
        drawBoard()
        
        backgroundColor = UIColor(white: 0.9, alpha: 1)
//        putCardsOnTable(cards: cards)
        setupUI()
    }
    
    func fillBoard(with cards: [Card]) {
        
//        guard cards.count >= columns * rows else { return }
        
        let scale = calculateCardScale(for: cards)
        
        // pass 1: fill empty slots with new cards
        var item = 0
        for row in 0..<rows {
            for column in 0..<columns {
                if board[row][column] == nil {
                    let card = GameCard(card: cards[item], initialScale: scale)
                    card.position = CGPoint(x: -1000, y: -1000)
                    addChild(card)
                    board[row][column] = card
                    item += 1
                }
            }
        }
//
//        // pass 2: fill other slots
//        for row in 0..<rows {
//            for column in 0..<columns+1 {
//                if board[row][column] == nil {
//                    let card = GameCard(card: cards[item], initialScale: scale)
//                    card.position = CGPoint(x: -1000, y: -1000)
//                    addChild(card)
//                    board[row][column] = card
//                    item += 1
//                }
//            }
//        }
        
    }
    
    func foundFirstGameCard(board: Board) -> GameCard? {
        for row in board {
            for item in row {
                if item != nil { return item! }
            }
        }
        return nil
    }
    
    func removeFromBoard(cards: [Card], redraw: Bool = false) {
        cards.forEach { (card) in
            for row in 0..<rows {
                for column in 0..<columns {
                    if board[row][column]?.card == card {
                        board[row][column]?.removeFromParent()
                        board[row][column] = nil
                    }
                }
            }
        }
    }
    
    func drawBoard() {
        guard let sampleGameCard = foundFirstGameCard(board: board) else { return }

        let width = sampleGameCard.size.width
        let height = sampleGameCard.size.height
        for row in 0..<rows {
            for column in 0..<columns {
                let x = CGFloat(column) * width + width / 2
                let y = CGFloat(row) * height + height / 2
                let position = CGPoint(x: x, y: y)
                if let card = board[row][column] {
                    card.position = position
                }
            }
        }

    }
    
    func calculateCardScale(for cards: [Card]) -> CGFloat {
        let sampleCard = GameCard(card: cards.first!)
        let ratio = sampleCard.size.width / sampleCard.size.height
        
        let estimatedWidth = (frame.width - CGFloat(columns + 1) * cardSpacing) / CGFloat(columns)
        let estimatedHeight = (frame.height - CGFloat(rows + 1) * cardSpacing) / CGFloat(rows)
        boardWidth = min(estimatedWidth, estimatedHeight * ratio)
        boardHeight = boardWidth / ratio
        
        let scale = boardWidth / sampleCard.size.width
        
        return scale
    }
    
    func setupUI() {
        let setButton = SKSpriteNode(imageNamed: "set-button-shadow")
        setButton.position = CGPoint(x: frame.width - 100, y: frame.midY)
        setButton.size = CGSize(width: 100,height: 100)
        setButton.name = "setButton"
        addChild(setButton)
        
        let findSetButton = SKSpriteNode(imageNamed: "set-button-shadow")
        findSetButton.position = CGPoint(x: frame.width - 100, y: frame.midY - 150)
        findSetButton.size = CGSize(width: 100,height: 100)
        findSetButton.name = "findSetButton"
        addChild(findSetButton)

        let redrawButton = SKSpriteNode(imageNamed: "set-button-shadow")
        redrawButton.position = CGPoint(x: frame.width - 100, y: frame.midY + 150)
        redrawButton.size = CGSize(width: 100,height: 100)
        redrawButton.name = "redrawButton"
        addChild(redrawButton)

    }
    
    
    func toggleCardSelection(card: GameCard) {
        if !card.isSelected {
            addToSelection(card: card)
        } else {
            if let index = selectedCards.firstIndex(of: card) {
                selectedCards.remove(at: index)
            }
        }
    }
    
    func addToSelection(card: GameCard) {
        if selectedCards.count == 3 {
            selectedCards.remove(at: selectedCards.index(selectedCards.startIndex, offsetBy: selectedCards.count - 1))
        }
        selectedCards.insert(card)
    }
    
    func redrawButtonTapped(on button: SKSpriteNode) {
        button.fadeTexture(to: SKTexture(imageNamed: "set-button"), duration: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            button.fadeTexture(to: SKTexture(imageNamed: "set-button-shadow"), duration: 0.2)
        }
        
        let newCards = game.draw()
        cards += newCards
        fillBoard(with: newCards)
        drawBoard()
    }
    
    func setButtonTapped(on button: SKSpriteNode) {
        button.fadeTexture(to: SKTexture(imageNamed: "set-button"), duration: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            button.fadeTexture(to: SKTexture(imageNamed: "set-button-shadow"), duration: 0.2)
        }
        if game.isSet(of: selectedCards.compactMap{ $0.card }) {
            print("!!! SET !!!")
            cards = game.setFound(set: selectedCards.compactMap{ $0.card })
            removeFromBoard(cards: selectedCards.compactMap{ $0.card })
            drawBoard()
        } else {
            print(" RIDI ")
        }
    }
    
    func findSetButtonTapped(on button: SKSpriteNode) {
        button.fadeTexture(to: SKTexture(imageNamed: "set-button"), duration: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            button.fadeTexture(to: SKTexture(imageNamed: "set-button-shadow"), duration: 0.2)
        }
        let currentSetOfCards = currentSet()
        selectedCards.removeAll(keepingCapacity: true)
        selectedCards.forEach({$0.isSelected = false})
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if let set = self.game.findSet(in: self.cards, except: currentSetOfCards) {
                let _ = self.children.filter { (node) -> Bool in
                    guard let card = node as? GameCard else { return false }
                    return set.contains(card.card)
                }.map({$0 as! GameCard})
                    .forEach({
                        self.selectedCards.insert($0)
                        $0.isSelected = true
                    })
            }
        }
    }
    
    func currentSet() -> [Card]? {
        guard selectedCards.count == 3 else { return nil }
        let possibleSet = selectedCards.map { $0.card }
        if game.isSet(of: possibleSet) {
            print("current set: \n\(possibleSet)")
            return possibleSet
        }
        return nil
    }
    
    func isSet(cards: [GameCard]) -> Bool {
        let set = cards.map{$0.card}
        return game.isSet(of: set)
    }
    
    func touchDown(atPoint pos: CGPoint) {
    }
    
    func touchMoved(toPoint pos: CGPoint) {
        
    }
    
    func touchUp(atPoint pos: CGPoint) {
        if let card = nodes(at: pos).first(where: { $0 is GameCard }) as? GameCard {
            toggleCardSelection(card: card)
        }
        
        if let button = nodes(at: pos).first(where: { $0.name == "setButton" }) as? SKSpriteNode {
            setButtonTapped(on: button)
        }
        
        if let button = nodes(at: pos).first(where: { $0.name == "findSetButton" }) as? SKSpriteNode {
            findSetButtonTapped(on: button)
        }

        if let button = nodes(at: pos).first(where: { $0.name == "redrawButton" }) as? SKSpriteNode {
            redrawButtonTapped(on: button)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        children.forEach { (node) in
            guard let card = node as? GameCard else { return }
            if selectedCards.contains(card) {
                if !card.isSelected {
                    card.isSelected = true
                }
            } else {
                if card.isSelected {
                    card.isSelected = false
                }
            }
        }
    }
}
