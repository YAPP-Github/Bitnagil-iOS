//
//  RoutineCategoryType.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Domain
import UIKit

extension RoutineCategoryType {
    var id: Int {
        switch self {
        case .recommendation: 1
        case .outdoor: 2
        case .outdoorReport: 3
        case .wakeup: 4
        case .connection: 5
        case .rest: 6
        case .growth: 7
        }
    }

    var title: String {
        switch self {
        case .recommendation: "맞춤 추천"
        case .outdoor: "나가봐요"
        case .outdoorReport: "나가봐요_제보"
        case .wakeup: "일어나요"
        case .connection: "연결해요"
        case .rest: "쉬어가요"
        case .growth: "성장해요"
        }
    }

    var iconImage: UIImage? {
        switch self {
        case .recommendation: nil
        case .outdoor, .outdoorReport: BitnagilIcon.outsideIcon
        case .wakeup: BitnagilIcon.wakeupIcon
        case .connection: BitnagilIcon.connectIcon
        case .rest: BitnagilIcon.restIcon
        case .growth: BitnagilIcon.growIcon
        }
    }

    var iconBackgroundColor: UIColor? {
        switch self {
        case .recommendation: nil
        case .outdoor, .outdoorReport: BitnagilColor.skyblue10
        case .wakeup: BitnagilColor.orange25
        case .connection: BitnagilColor.purple10
        case .rest: BitnagilColor.green10
        case .growth: BitnagilColor.pink10
        }
    }
}
