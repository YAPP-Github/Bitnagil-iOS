//
//  NSAttributedString+.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import Foundation

extension NSAttributedString {
    static func highlighted(text: String, highlightText: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        attributedString.addAttribute(
            .font,
            value: BitnagilFont(style: .body2, weight: .regular).font,
            range: NSRange(location: 0, length: text.count)
        )

        if let range = text.range(of: highlightText) {
            let nsRange = NSRange(range, in: text)
            attributedString.addAttribute(
                .font,
                value: BitnagilFont(style: .body2, weight: .semiBold).font,
                range: nsRange
            )
        }
        return attributedString
    }
}
