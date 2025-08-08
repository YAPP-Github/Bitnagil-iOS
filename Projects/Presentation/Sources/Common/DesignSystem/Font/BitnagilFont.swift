//
//  BitnagilFont.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import UIKit

struct BitnagilFont {
    let style: FontStyle
    let weight: FontWeight

    init(style: FontStyle, weight: FontWeight) {
        self.style = style
        self.weight = weight
    }

    init(fontSize: CGFloat,
         lineHeight: CGFloat,
         letterSpacing: CGFloat = 0,
         underline: Bool = false,
         weight: FontWeight
    ) {
        let attributes = FontAttributes(
            fontSize: fontSize,
            lineHeight: lineHeight,
            letterSpacing: letterSpacing,
            underline: underline)
        self.style = .custom(fontAttribute: attributes)
        self.weight = weight
    }

    var font: UIFont {
        guard let font = UIFont(name: weight.fontName, size: style.fontAttributes.fontSize) else {
            return UIFont.systemFont(ofSize: style.fontAttributes.fontSize)
        }
        return font
    }

    func attributedString(text: String?) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = style.fontAttributes.lineHeight
        paragraphStyle.minimumLineHeight = style.fontAttributes.lineHeight

        var attributes:  [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: paragraphStyle,
            .kern: style.fontAttributes.letterSpacing]
        if style.fontAttributes.underline {
            attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }

        return NSAttributedString(
            string: text ?? "Loading···",
            attributes: attributes)
    }
}
