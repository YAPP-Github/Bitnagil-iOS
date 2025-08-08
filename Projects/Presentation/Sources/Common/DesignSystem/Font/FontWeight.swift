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

    var fontName: String {
        switch self {
        case .bold: "Pretendard-Bold"
        case .semiBold: "Pretendard-SemiBold"
        case .medium: "Pretendard-Medium"
        case .regular: "Pretendard-Regular"
        }
    }
}
