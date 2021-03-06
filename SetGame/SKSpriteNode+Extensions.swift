//
//  SKSpriteNode+Extensions.swift
//  SetGame
//
//  Created by Hadi Sharghi on 3/27/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import SpriteKit

extension SKSpriteNode {
    func drawBorder(color: UIColor, width: CGFloat, offset: CGFloat = 0, name: String? = nil) {
        let borderFrame = offset > 0 ?
            frame.offsetBy(dx: offset, dy: offset) :
            frame.insetBy(dx: offset, dy: offset)
        let shapeNode = SKShapeNode(rect: borderFrame)
        shapeNode.fillColor = .clear
        shapeNode.strokeColor = color
        shapeNode.lineWidth = width
        shapeNode.name = name
        addChild(shapeNode)
    }
    
    func fadeTexture(to newTexture: SKTexture, duration: CFTimeInterval) {
        let fadeInSpriteNode = fadeInSprite(with: newTexture, spriteNode: self)
        self.parent?.addChild(fadeInSpriteNode)
        fadeInSpriteNode.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 1, duration: duration),
            SKAction.run {
                fadeInSpriteNode.removeFromParent()
                self.texture = newTexture
            }
        ]))
    }
    
    private func fadeInSprite(with texture: SKTexture, spriteNode: SKSpriteNode) -> SKSpriteNode {
        let fadeInSprite = SKSpriteNode(texture: texture, size: spriteNode.size)
        fadeInSprite.alpha = 0
        fadeInSprite.anchorPoint = spriteNode.anchorPoint
        fadeInSprite.position = spriteNode.position
        
        return fadeInSprite
    }
    
}

