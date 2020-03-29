//
//  GameCard.swift
//  SetGame
//
//  Created by Hadi Sharghi on 3/28/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//


import SpriteKit
import SetGameEngine

class GameCard: SKSpriteNode {

    static let colorRed = UIColor(hex: "d22519")
    static let colorGreen = UIColor(hex: "0b930b")
    static let colorBlue = UIColor(hex: "0033cc")
    
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
            return GameCard.colorBlue
        case .green:
            return GameCard.colorGreen
        case .red:
            return GameCard.colorRed
        }
    }
    
    private func setSelected(selected: Bool) {
        if selected {
            self.zPosition = 100
            self.fadeTexture(to: SKTexture(imageNamed: "shadow"), duration: 0.1)
            self.run(SKAction.scale(to: selectionScale, duration: 0.1))
        } else {
            self.zPosition = 0
            self.fadeTexture(to: SKTexture(imageNamed: "card"), duration: 0.1)
            self.run(SKAction.scale(to: 1, duration: 0.1))
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

