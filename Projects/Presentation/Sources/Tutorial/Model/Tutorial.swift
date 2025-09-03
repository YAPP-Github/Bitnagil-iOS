//
//  Tutorial.swift
//  Presentation
//
//  Created by 최정인 on 9/3/25.
//

import UIKit

enum Tutorial: CaseIterable {
    case emotionRegister
    case homeMore
    case recommendationRoutine
    case editRoutine

    var title: String {
        switch self {
        case .emotionRegister:
            "오늘 감정 등록하기란?"
        case .homeMore:
            "홈에서 더보기란?"
        case .recommendationRoutine:
            "맞춤 추천 루틴이란?"
        case .editRoutine:
            "루틴 수정하기란?"
        }
    }

    var description: String {
        switch self {
        case .emotionRegister:
            "오늘 느끼는 감정을 선택하면, 그 기분에 맞춰 추천 루틴을\n확인할 수 있어요."
        case .homeMore:
            "루틴 리스트에서 세부 항목(세부 루틴, 반복, 기간, 시간)을\n확인하고, 필요 시 수정하거나 삭제할 수 있어요."
        case .recommendationRoutine:
            "처음 설정한 목표에 맞춰 루틴을 추천받을 수 있으며,\n필요할 때 언제든 수정할 수 있어요."
        case .editRoutine:
            "등록한 루틴은 수정할 수 있으며, 변경 내용을 당일부터 또는\n다음 날부터 적용하도록 선택할 수 있어요."
        }
    }

    var tutorialImage: UIImage? {
        switch self {
        case .emotionRegister:
            BitnagilGraphic.tutorialEmotionGraphic
        case .homeMore:
            BitnagilGraphic.tutorialHomeMoreGraphic
        case .recommendationRoutine:
            BitnagilGraphic.tutorialRecommendationRoutineGraphic
        case .editRoutine:
            BitnagilGraphic.tutorialEditRoutineGraphic
        }
    }
}
