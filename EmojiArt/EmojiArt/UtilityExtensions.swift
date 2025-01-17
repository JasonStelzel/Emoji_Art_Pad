//
//  UtilityExtensions.swift
//  EmojiArt
//
//  Created by Jason Stelzel on 8/17/22.
//

import SwiftUI

// In a Collection of Identifiables we often might want to find the element
// that has the same id as an Identifiable we already have in hand.
// We name this index(matching:) instead of firstIndexmatching:)
// because we assume that someone creating a Collection of Identifiable
// is usually going to have only one of each Identifiable thing in there
// (though there's nothing to restrict them from doing so; it's just a naming choince)

extension Collection where Element: Identifiable {
    func index(matching element: Element) -> Self.Index? {
        firstIndex(where: { $0.id == element.id })
    }
}

// We could do the same thing when it comes to removing an element
// but we have to add that to a different protocol
// because Collection works for immutable collections of things.
// The "mutable" one is RangeReplaceableCollection.
// Not only could we add remove but we could add a subscript
// which takes a copy of one of the elements and uses its Identifiable-ness
// to subscript into the Collection.
// This is an awesome way to create Bindings into an Array in a ViewModel
// (since any Published var in an ObservableObject can be bound to via $)
// (even vars on that Published var or subscripts on that var)
// (or subscripts on vars on that var, etc.)

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


extension Character {
// Swift does not have a way to ask if a Character isEmoji
// but it does let us check to see if our componenent scalars isEmoji.
// Unfortunately, Unicode allows certain scalars (like 1) to be modified by another scalar
// to become emoji (e.g. 1️⃣) so the scalar "1" will report isEmoji = true
// so we can't just check to see if the first scalar isEmoji.
// The quick and dirty here is to see if the scalar is at least the first true emoji we know of
// (the start of the "miscellaneious items" section)
// or check to see if this is a multiple scalar unicode sequence
// (e.g. a 1 with a unicode modifier to force it to be presented as emoji 1️⃣)
    var isEmoji: Bool {
        if let firstScalar = unicodeScalars.first, firstScalar.properties.isEmoji {
            return (firstScalar.value >= 0x238d || unicodeScalars.count > 1)
        } else {
            return false
        }
    }
}

// Because urls are sometimes wrapped in another url (like when they come from Google)
// this is an extension on URL that extracts the actual url for an imageUrl
// that might contain other info (essentially looking for the imgurl key)
// *imgurl* is a "well known" key that can be embedded in a url that indicates what the actual image url is

extension URL {
    var imageURL: URL {
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return baseURL ?? self
    }
}


// Geometry extensions

extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}


extension CGPoint {
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    static func +(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func -(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}


extension CGSize {
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }

}


// Convenience functions for [NSItemProvider] (i.e. array of NSItemProvider)
// makes the code for loading objects from the providers a bit simpler.
// NSItemProvider is a holdover from the Obejctive-C world (i.e. pre-Swift)
// as indicated by its "NS" style prefix (from NextStep,
// the company founded by Steve Jobs when he left Apple at one point).

extension Array where Element == NSItemProvider {
    
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) {object, error in
                if let value = object as? T {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    func loadObjects<T>(ofType theType: T.Type, firstOnly: Bool = false, using load: @escaping (T) -> Void) -> Bool where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderReading {
        if let provider = first(where: { $0.canLoadObject(ofClass: theType) }) {
            let _ = provider.loadObject(ofClass: theType) {object, error in
                if let value = object {
                    DispatchQueue.main.async {
                        load(value)
                    }
                }
            }
            return true
        }
        return false
    }
    
    
}

