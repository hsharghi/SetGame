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
    
    var card: Card
    var isSelected: Bool = false
    
    init(card: Card) {
        self.card = card
        let bgtexture = SKTexture(imageNamed: "card")
        super.init(texture: bgtexture, color: SKColor.clear, size: bgtexture.size())
        
        var icons: [SKSpriteNode]
        let shader = GameCard.createColorNonAlpha(color: GameCard.getCardColor(card: card))
        icons = (1...card.count).map { _ in SKSpriteNode(texture: SKTexture(imageNamed: GameCard.getFileName(for: card))) }
        icons.forEach { $0.shader = shader }
        switch card.count {
        case 1:
            if let icon = icons.first {
                icon.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
                self.addChild(icon)
            }
        case 2:
            let icon1 = icons[0]
            let icon2 = icons[1]
            icon1.position = CGPoint(x: self.frame.midX, y: self.frame.midY + icon1.size.height - 25)
            icon2.position = CGPoint(x: self.frame.midX, y: self.frame.midY - icon1.size.height + 25)
            self.addChild(icon1)
            self.addChild(icon2)
            
        case 3:
            let icon1 = icons[0]
            let icon2 = icons[1]
            let icon3 = icons[2]
            icon1.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            icon2.position = CGPoint(x: self.frame.midX, y: self.frame.midY + icon1.size.height + 50)
            icon3.position = CGPoint(x: self.frame.midX, y: self.frame.midY - icon1.size.height - 50)
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
    
}

class GameScene: SKScene {
    
    var game = Engine(players: 1)
    var cards = [Card]()
    
    let cardSpacing: CGFloat = 10
    let columns = 4
    let rows = 3
    
    override func didMove(to view: SKView) {
        cards = game.draw()
        //        let width = min(2 * estimatedWidth, estimatedHeight)
        
        let sampleCard = GameCard(card: cards.first!)
        let ratio = sampleCard.size.width / sampleCard.size.height
        
        let estimatedWidth = (frame.width - CGFloat(columns + 1) * cardSpacing) / CGFloat(columns)
        let estimatedHeight = (frame.height - CGFloat(rows + 1) * cardSpacing) / CGFloat(rows)
        let width = min(estimatedWidth, estimatedHeight * ratio)
        let height = width / ratio
        
        let scale = width / sampleCard.size.width
        var item = 0
    
        let toHeight = height * CGFloat(rows) + CGFloat(rows + 1) * cardSpacing
        let toWidth = width * CGFloat(columns) + CGFloat(columns + 1) * cardSpacing
                
        var column = 1
        var row = 1
        for j in stride(from: height / 2, through: toHeight, by: height) {
            for i in stride(from: width / 2, through: toWidth, by: width) {
                print("row: \(row) - column: \(column)")
                if item >= 12 { continue }
                let card = GameCard(card: cards[item])
                print(cards[item])
                card.position = CGPoint(x: i + CGFloat(column) * cardSpacing, y: j + CGFloat(row) * cardSpacing)
                card.setScale(scale)
                print(card.position)
                addChild(card)
                item += 1
                column += 1
            }
            row += 1
            column = 1
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
