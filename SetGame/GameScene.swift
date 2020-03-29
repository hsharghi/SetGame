//
//  GameScene.swift
//  SetGame
//
//  Created by Hadi Sharghi on 3/26/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import SpriteKit
import SetGameEngine

class GameScene: SKScene {
    
    typealias Board = [[GameCard?]]
    
    var game = Engine(players: 1)
    var cards = [Card]()
    var board: GameBoard?
    var selectedCards = Set<GameCard>()
    
    
    override func didMove(to view: SKView) {
        
        backgroundColor = UIColor(white: 0.9, alpha: 1)

        board = GameBoard(rows: 3, columns: 4, spacing: 5, scene: self)
        
        cards = game.draw()
        game.delegate = self
        
        
        board?.fill(with: cards)
        board?.draw()
        
        setupUI()
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
        board?.fill(with: newCards)
        board?.draw()
    }
    
    func setButtonTapped(on button: SKSpriteNode) {
        button.fadeTexture(to: SKTexture(imageNamed: "set-button"), duration: 0.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            button.fadeTexture(to: SKTexture(imageNamed: "set-button-shadow"), duration: 0.2)
        }
        if game.isSet(of: selectedCards.compactMap{ $0.card }) {
            print("!!! SET !!!")
            cards = game.setFound(set: selectedCards.compactMap{ $0.card })
            board?.remove(cards: selectedCards.compactMap{ $0.card })
            board?.draw()
            selectedCards.removeAll()
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
    
    func alert(text: String, color: UIColor = .black) {
        children.first(where: {$0 is SKLabelNode})?.removeFromParent()
        
        let label = SKLabelNode(text: text)
        label.color = color
        label.position = CGPoint(x: frame.midX, y: frame.maxY)
        label.setScale(0.00001)
        label.alpha = 0
        addChild(label)
        SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 1, duration: 0.5),
                SKAction.scale(to: 1, duration: 0.5),
            ]),
            SKAction.wait(forDuration: 0.2),
            SKAction.group([
                SKAction.fadeAlpha(to: 0, duration: 0.5),
                SKAction.scale(to: 10, duration: 0.5)
            ]),
        ])
    }
    
}


extension GameScene: GameEngineDelegate {
    func noSetFound() {
        
        alert(text: "No set found")
        
        print("no set found")
        if board?.cardCount == 12 {
            cards = game.redraw()
            board?.empty()
            board?.fill(with: cards)
            board?.draw()
        }
    }
    
    func noMoreCards() {
        print("no more cards")
    }
    
    func gameEnded() {
        print("game ended")
    }
    
    
}
