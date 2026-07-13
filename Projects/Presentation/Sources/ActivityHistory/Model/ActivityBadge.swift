//
//  ActivityBadge.swift
//  Presentation
//
//  Created by 최정인 on 7/7/26.
//

import UIKit

enum ActivityBadge {
    case emotionBadge
    case routineBadge
    case reportBadge

    var badgeTitle: String {
        switch self {
        case .emotionBadge: "점점 감정에\n솔직해지고 계시네요!"
        case .routineBadge: "큰 성취를\n이루셨군요, 대단해요!"
        case .reportBadge: "덕분에 도시가\n개선되고 있어요!"
        }
    }

    var expertTitle: String? {
        switch self {
        case .emotionBadge: "의욕 전문가"
        case .routineBadge: "체크 전문가"
        case .reportBadge: "외출 전문가"
        }
    }

    // TODO: 추후 서버에서 이미지 url 값을 받는다면, 수정될 가능성 있음
    var singleImage: UIImage? {
        switch self {
        case .emotionBadge: BitnagilGraphic.emotionSingleBadgeGraphic
        case .routineBadge: BitnagilGraphic.routineSingleBadgeGraphic
        case .reportBadge: BitnagilGraphic.reportSingleBadgeGraphic
        }
    }

    var multipleImage: UIImage? {
        switch self {
        case .emotionBadge: BitnagilGraphic.emotionMultipleBadgeGraphic
        case .routineBadge: BitnagilGraphic.routineMultipleBadgeGraphic
        case .reportBadge: BitnagilGraphic.reportMultipleBadgeGraphic
        }
    }
}
