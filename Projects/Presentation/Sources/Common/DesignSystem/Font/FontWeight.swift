//
//  FontWeight.swift
//  Presentation
//
//  Created by 최정인 on 7/7/25.
//

enum FontWeight {
    case bold
    case semiBold
    case medium
    case regular
    case light

    var pretendardFontName: String {
        switch self {
        case .bold: "Pretendard-Bold"
        case .semiBold: "Pretendard-SemiBold"
        case .medium: "Pretendard-Medium"
        case .regular: "Pretendard-Regular"
        default: "Pretendard-Medium"
        }
    }

    var cafe24FontName: String {
        switch self {
        case .light: "Cafe24SsurroundairOTF"
        default: "Cafe24SsurroundairOTF"
        }
    }
}
