//
//  UtilityViews.swift
//  EmojiArt
//
//  Created by Jason Stelzel on 9/15/22.
//

import SwiftUI

// syntactic sugar to be able to pass an option UIImage to Image
// (normally it sould only take a non-optional UIImage)

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        if uiImage != nil {
            Image(uiImage: uiImage!)
        }
    } // otherwise do nothing (i.e. return an empty view body to satisfy the requirement)
}
