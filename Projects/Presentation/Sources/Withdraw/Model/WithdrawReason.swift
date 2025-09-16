//
//  WithdrawReason.swift
//  Presentation
//
//  Created by 최정인 on 9/5/25.
//

enum WithdrawReason: BitnagilChoiceProtocol, CaseIterable {
    case notMatching
    case uncomfortable
    case appError

    var title: String {
        switch self {
        case .notMatching:
            "루틴이 생활 패턴과 맞지 않아요."
        case .uncomfortable:
            "기능이 복잡하거나 사용이 불편해요."
        case .appError:
            "앱이 자주 멈추거나 오류가 발생해요."
        }
    }

    var subTitle: String? {
        return nil
    }
}
