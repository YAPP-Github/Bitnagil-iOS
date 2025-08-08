//
//  FontStyle.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

enum FontStyle {
    case headline1
    case headline2

    case title1
    case title2
    case title3

    case subtitle1

    case body1
    case body2

    case caption1
    case caption2
    case captionUnderline1

    case button1
    case button2

    case custom(fontAttribute: FontAttributes)

    var fontAttributes: FontAttributes {
        switch self {
        case .headline1: FontAttributes(fontSize: 26, lineHeight: 38, letterSpacing: -0.5)
        case .headline2: FontAttributes(fontSize: 24, lineHeight: 34, letterSpacing: -0.5)

        case .title1: FontAttributes(fontSize: 22, lineHeight: 32, letterSpacing: -0.5)
        case .title2: FontAttributes(fontSize: 20, lineHeight: 30)
        case .title3: FontAttributes(fontSize: 18, lineHeight: 24)

        case .subtitle1: FontAttributes(fontSize: 16, lineHeight: 28)

        case .body1: FontAttributes(fontSize: 16, lineHeight: 24)
        case .body2: FontAttributes(fontSize: 14, lineHeight: 20)

        case .caption1: FontAttributes(fontSize: 12, lineHeight: 18)
        case .caption2: FontAttributes(fontSize: 10, lineHeight: 16)
        case .captionUnderline1: FontAttributes(fontSize: 12, lineHeight: 18, underline: true)

        case .button1: FontAttributes(fontSize: 16, lineHeight: 24)
        case .button2: FontAttributes(fontSize: 14, lineHeight: 20)

        case .custom(let fontAttribute): fontAttribute
        }
    }
}
