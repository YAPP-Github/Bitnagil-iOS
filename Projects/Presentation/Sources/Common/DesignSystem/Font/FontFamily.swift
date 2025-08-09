//
//  FontFamily.swift
//  Presentation
//
//  Created by 최정인 on 8/9/25.
//

enum FontFamily {
    case pretendard
    case cafe24Ssurround

    func fontName(weight: FontWeight) -> String {
        switch self {
        case .pretendard:
            return weight.pretendardFontName
        case .cafe24Ssurround:
            return weight.cafe24FontName
        }
    }
}
