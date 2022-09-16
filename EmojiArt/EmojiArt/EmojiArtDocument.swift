//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Jason Stelzel on 8/17/22.
//

import SwiftUI

// ViewModel
class EmojiArtDocument: ObservableObject {
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background {
                fetchBackgroundImageDataIfNecessary()
            }
        }
    }
    
    init() {
        emojiArt = EmojiArtModel()
//        emojiArt.addEmoji("😃", at: (-200,-100), size: 80) // default test object
//        emojiArt.addEmoji("🚀", at: (50,100), size: 140) // default test object
    }
    
    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }
    var background: EmojiArtModel.Background { emojiArt.background }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundImageFetchStatus = BackgroundImageFetchStatus.idle
    
    enum BackgroundImageFetchStatus {
        case idle
        case fetching
    }
    
    private func fetchBackgroundImageDataIfNecessary() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // fetch image from url asynchronously on background thread
            backgroundImageFetchStatus = .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                // begin potential update of UI on main thread
                    DispatchQueue.main.async { [weak self] in
                        self?.backgroundImageFetchStatus = .idle
                        // first check if intent is still valid (user may have moved on, changed mind, executed request for new background)
                        if self?.emojiArt.background == EmojiArtModel.Background.url(url) {
                            // then ensure that request itself is valid and server responded with valid data from requested url
                            if imageData != nil {
                                self?.backgroundImage = UIImage(data: imageData!)
                            }
                        }
                    }
                }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intent(s)
    
    func setBackground(_ background: EmojiArtModel.Background) {
        print ("Set background to \(background)")
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: (x: Int, y: Int), size: CGFloat) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
            
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrAwayFromZero))
        }
    }
    
}

