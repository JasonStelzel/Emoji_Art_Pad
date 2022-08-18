//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by Jason Stelzel on 8/17/22.
//

import SwiftUI

// In a Collection of Identifiables we often might want to find the element that has the same id as ana Identifiable we already have in hand. We name this index(matching:) instead of firstIndexmatching:) because we assume that someone creating a Collection of Identifiable is usually going to have only one of each Identifiable thing in there (though there's nothing to restrict them from doing so; it's just a naming choince)

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

// We could do the same thing when it comes to removing an element but we have to add that to a different protocol because Collection works for immutable collections of things.  The "mutable" one is RangeReplaceableCollection.  Not only could we add remove but we could add a subscript which takes a copy of one of the elements and uses its Identifiable-ness to subscript into the Collection.  This is an awesome way to create Bindings into an Array in a ViewModel (since any Published var in an ObservableObject can be bound to via $) (even vars on that Published var or subscripts on that var) (or subscripts on vars on that var, etc.)

extension RangeReplaceableCollection where Element: Identifiable {
    mutating func remove(_ element: Element) {
        if let index = index(matching: element) {
            remove(at: index)
        }
    }
    
    subscript(_ element: Element) -> Element {
        get {
            if let index = index(matching: element) {
                return self[index]
            } else {
                return element
            }
        }
        set {
            if let index = index(matching: element) {
                replaceSubrange(index...index, with: [newValue])
            }
        }
    }
}
