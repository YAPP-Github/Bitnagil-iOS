//
//  Emotion.swift
//  Presentation
//
//  Created by 최정인 on 7/29/25.
//

import Domain
import Foundation
import UIKit

struct Emotion: Hashable {
    let id = UUID()
    let emotionType: String
    let emotionTitle: String
    let emotionImageUrl: URL?
    let emotionMessage: String?
    // TODO: - 서버 연동 후 삭제
    var image: UIImage?
    var fomoImage: UIImage?
    var textColor: UIColor?
    var backgroundColor: UIColor?
    var titleDescription: String?

    func copy() -> Emotion {
        return .init(
            emotionType: emotionType,
            emotionTitle: emotionTitle,
            emotionImageUrl: emotionImageUrl,
            emotionMessage: emotionMessage,
            image: image,
            fomoImage: fomoImage,
            textColor: textColor,
            backgroundColor: backgroundColor,
            titleDescription: titleDescription)
    }
}

extension EmotionEntity {
    func toEmotion() -> Emotion {
        return Emotion(
            emotionType: emotionType,
            emotionTitle: emotionName,
            emotionImageUrl: emotionImageUrl,
            emotionMessage: emotionMessage)
    }
}

// TODO: - 서버 연동 후 삭제
let emotinonDummies: [Emotion] = Marble.allCases.map { Emotion(
    emotionType: $0.rawValue,
    emotionTitle: $0.name,
    emotionImageUrl: nil,
    emotionMessage: $0.description,
    image: $0.marbleImage,
    textColor: $0.textColor,
    backgroundColor: $0.backgroundColor,
    titleDescription: $0.koreanDescription)}

enum Marble:String, CaseIterable {
    case NONE
    case CALM
    case VITALITY
    case LETHARGY
    case ANXIETY
    case SATISFACTION
    case FATIGUE

    var backgroundColor: UIColor? {
        switch self {
        case .NONE:
            return BitnagilColor.gray97
        case .CALM:
            return BitnagilColor.purple5
        case .VITALITY:
            return BitnagilColor.green5
        case .LETHARGY:
            return BitnagilColor.gray95
        case .ANXIETY:
            return BitnagilColor.orange50
        case .SATISFACTION:
            return BitnagilColor.mint10
        case .FATIGUE:
            return BitnagilColor.red10
        }
    }

    var textColor: UIColor? {
        switch self {
        case .NONE:
            return BitnagilColor.gray10
        case .CALM:
            return BitnagilColor.purple500
        case .VITALITY:
            return BitnagilColor.green500
        case .LETHARGY:
            return BitnagilColor.gray30
        case .ANXIETY:
            return BitnagilColor.orange500
        case .SATISFACTION:
            return BitnagilColor.mint500
        case .FATIGUE:
            return BitnagilColor.red500
        }
    }

    var marbleImage: UIImage? {
        switch self {
        case .NONE:
            return BitnagilGraphic.marbleNoneGraphic
        case .CALM:
            return BitnagilGraphic.marblePurpleGraphic
        case .VITALITY:
            return BitnagilGraphic.marbleGreenGraphic
        case .LETHARGY:
            return BitnagilGraphic.marbleGrayGraphic
        case .ANXIETY:
            return BitnagilGraphic.marbleOrangeGraphic
        case .SATISFACTION:
            return BitnagilGraphic.marbleMintGraphic
        case .FATIGUE:
            return BitnagilGraphic.marbleRedGraphic
        }
    }

    var name: String {
        switch self {
        case .NONE:
            "구슬 선택"
        case .CALM:
            "평온함"
        case .VITALITY:
            "활기참"
        case .LETHARGY:
            "무기력함"
        case .ANXIETY:
            "불안함"
        case .SATISFACTION:
            "만족함"
        case .FATIGUE:
            "피곤함"
        }
    }

    var koreanDescription: String {
        switch self {
        case .NONE:
            return "구슬 선택"
        case .CALM:
            return "평온한"
        case .VITALITY:
            return "활기찬"
        case .LETHARGY:
            return "무기력한"
        case .ANXIETY:
            return "불안한"
        case .SATISFACTION:
            return "만족하는"
        case .FATIGUE:
            return "피곤한"
        }
    }

    var description: String {
        switch self {
        case .NONE:
            """
            오늘 기분 어때요?
            기록해 두면 내 루틴에 도움 돼요
            """
        case .CALM:
            """
            평온함은 마음이 고요하고 편안해
            균형을 이루는 상태예요.
            """
        case .VITALITY:
            """
            활기참은 생기가 가득 차
            활발하고 적극적인 상태예요.
            """
        case .LETHARGY:
            """
            무기력함은 의욕이 없어 아무것도
            하기 힘든 상태예요.
            """
        case .ANXIETY:
            """
            불안함은 마음이 불안정하고 쉽게
            안심하기 어려운 상태예요.
            """
        case .SATISFACTION:
            """
            만족함은 기대가 충족되어
            더 바랄 것이 없는 상태예요.
            """
        case .FATIGUE:
            """
            피곤함은 몸과 마음이 지쳐
            휴식이 필요한 상태예요.
            """
        }
    }
}
