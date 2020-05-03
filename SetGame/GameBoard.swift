//
//  GameBoard.swift
//  SetGame
//
//  Created by Hadi Sharghi on 3/28/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import SpriteKit
import SetGameEngine

class GameBoard {
    typealias Board = [[GameCard?]]

    private var board: Board
    private var scene: SKScene
    private var rows: Int
    private var columns: Int
    private var cardSpacing: CGFloat
    private var width: CGFloat = 0
    private var height: CGFloat = 0

    init(rows: Int, columns: Int, spacing: CGFloat, scene: SKScene) {
        self.rows = rows
        self.columns = columns
        self.cardSpacing = spacing
        self.scene = scene
        board = Board(repeating: [GameCard?](repeating: nil, count: columns + 1), count: rows)
    }
    
    public var cardCount: Int {
        var count = 0
        for row in board {
            for card in row {
                count += card == nil ? 0 : 1
            }
        }
        
        return count
    }
    
    public func fill(with cards: [Card]) {
        guard cards.count > 0 else { return }
        
        let scale = calculateCardScale(for: cards, in: scene)
        
        // pass 1: fill empty slots with new cards
        var item = 0
        for row in 0..<rows {
            for column in 0..<columns {
                if board[row][column] == nil {
                    let card = GameCard(card: cards[item], initialScale: scale)
                    card.position = CGPoint(x: -1000, y: -1000)
                    scene.addChild(card)
                    board[row][column] = card
                    item += 1
                }
            }
        }
    }
    
    public func empty() {
        for row in 0..<rows {
            for column in 0..<columns {
                board[row][column]?.removeFromParent()
                board[row][column] = nil
            }
        }
    }
    
    public func remove(cards: [Card], redraw: Bool = false) {
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
    
    public func drawGameInfo(player: GamePlayer, remainingCards: Int) {
        var playerName: SKLabelNode
        var remainingCardsLabel: SKLabelNode
        var score: SKLabelNode
        
        if let label =  scene.childNode(withName: "playerName") as? SKLabelNode {
            playerName = label
        } else {
            playerName = SKLabelNode(text: player.name)
            playerName.name = "playerName"
            playerName.fontColor = .black
            playerName.position = CGPoint(x: scene.frame.width - 100, y: 150)
            scene.addChild(playerName)
        }
        if let label =  scene.childNode(withName: "remainingCards") as? SKLabelNode {
            remainingCardsLabel = label
            remainingCardsLabel.text =  "Remaining cards: \(remainingCards)"
        } else {
            remainingCardsLabel = SKLabelNode(text: "Remaining cards: \(remainingCards)")
            remainingCardsLabel.name = "remainingCards"
            remainingCardsLabel.fontColor = .black
            remainingCardsLabel.position = CGPoint(x: scene.frame.width - 150, y: 100)
            scene.addChild(remainingCardsLabel)
        }

        if let label =  scene.childNode(withName: "scoreLabel") as? SKLabelNode {
            score = label
            score.text = "Score: \(player.score)"
        } else {
            score = SKLabelNode(text: "Score: \(player.score)")
            score.name = "scoreLabel"
            score.fontColor = .black
            score.position = CGPoint(x: scene.frame.width - 150, y: 50)
            scene.addChild(score)
        }
    }
    
    public func draw() {
        guard let sampleGameCard = foundFirstGameCard(board: board) else { return }

        let width = sampleGameCard.size.width
        let height = sampleGameCard.size.height
        for row in 0..<rows {
            for column in 0..<columns {
                let x = CGFloat(column) * width + width / 2 + CGFloat(column + 1) * cardSpacing
                let y = CGFloat(row) * height + height / 2 + CGFloat(row + 1) * cardSpacing
                let position = CGPoint(x: x, y: y)
                if let card = board[row][column] {
                    card.position = position
                }
            }
        }


    }
    
    
    private func foundFirstGameCard(board: Board) -> GameCard? {
        for row in board {
            for item in row {
                if item != nil { return item! }
            }
        }
        return nil
    }
    
    
    private func calculateCardScale(for cards: [Card], in scene: SKScene) -> CGFloat {
        let sampleCard = GameCard(card: cards.first!)
        let ratio = sampleCard.size.width / sampleCard.size.height
        
        let estimatedWidth = (scene.frame.width - CGFloat(columns + 1) * cardSpacing) / CGFloat(columns)
        let estimatedHeight = (scene.frame.height - CGFloat(rows + 1) * cardSpacing) / CGFloat(rows)
        width = min(estimatedWidth, estimatedHeight * ratio)
        height = width / ratio
        
        let scale = width / sampleCard.size.width
        
        return scale
    }

}
