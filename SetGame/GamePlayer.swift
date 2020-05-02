//
//  GamePlayer.swift
//  SetGame
//
//  Created by Hadi Sharghi on 5/2/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import Foundation
import SetGameEngine

class GamePlayer: SetPlayer {
    var cardsWon = [Card]()
    var _ID: Int
    var name: String
    typealias PlayerID = Int
    
    init(id: Int, name: String? = nil) {
        self._ID = id
        self.name = name ?? "Player \(id)"
    }
    
    required init(id: Int) {
        self._ID = id
        self.name = "Player \(id)"
    }
    
    var score: Int {
        return cardsWon.count
    }
    
    func addScoreCards(cards: [Card]) {
        cardsWon.append(contentsOf: cards)
    }
    
    func removeFromScore(numberOfCards: Int) -> [Card] {
        var removedCards = [Card]()
        guard numberOfCards < cardsWon.count else {
            removedCards = cardsWon
            cardsWon.removeAll()
            return removedCards
        }
        
        for index in 0..<numberOfCards {
            removedCards.append(cardsWon.shuffled()[index])
        }
        
        cardsWon.remove(objects: removedCards)
        return removedCards
    }
    
}

extension GamePlayer: Equatable {
    static func == (lhs: GamePlayer, rhs: GamePlayer) -> Bool {
        lhs._ID == rhs._ID
    }

}
