//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Jason Stelzel on 8/17/22.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
