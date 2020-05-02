//
//  Array+Extensions.swift
//  SetGame
//
//  Created by Hadi Sharghi on 5/2/20.
//  Copyright © 2020 Hadi Sharghi. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Int? {
        if let index = firstIndex(of: object) {
            self.remove(at: index)
            return index
        }
        return nil
    }
    
    @discardableResult mutating func remove(objects: [Element]) -> [Int] {
        var removedIndices = [Int]()
        objects.forEach { object in
            if let index = remove(object: object) {
                removedIndices.append(index)
            }
        }
        return removedIndices
    }
    
    @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
        if let index = self.firstIndex(where: { (element) -> Bool in
            return predicate(element)
        }) {
            self.remove(at: index)
            return true
        }
        return false
    }
    

}

extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}


extension Collection {
    
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
    
}
