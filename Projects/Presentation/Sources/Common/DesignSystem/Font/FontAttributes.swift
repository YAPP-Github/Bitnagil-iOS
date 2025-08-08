//
//  FontAttributes.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

import Foundation

struct FontAttributes {
    let fontSize: CGFloat
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    let underline: Bool

    init(
        fontSize: CGFloat,
        lineHeight: CGFloat,
        letterSpacing: CGFloat = 0,
        underline: Bool = false
    ) {
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.underline = underline
    }
}
