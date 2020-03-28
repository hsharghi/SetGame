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

    var board: Board
    var width: CGFloat = 0
    var height: CGFloat = 0
    private var scene: SKScene
    private var rows: Int
    private var columns: Int
    private var cardSpacing: CGFloat
    
    init(rows: Int, columns: Int, spacing: CGFloat, scene: SKScene) {
        self.rows = rows
        self.columns = columns
        self.cardSpacing = spacing
        self.scene = scene
        board = Board(repeating: [GameCard?](repeating: nil, count: columns + 1), count: rows)
    }
    
    public func fill(with cards: [Card]) {
        
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