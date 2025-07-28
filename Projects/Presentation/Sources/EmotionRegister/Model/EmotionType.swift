//
//  EmotionType.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import UIKit

enum EmotionType: CaseIterable {
    case calm
    case lethargy
    case vitality
    case anxiety
    case satisfied
    case tired

    var title: String {
        switch self {
        case .calm: "평온함"
        case .lethargy: "무기력함"
        case .vitality: "활기참"
        case .anxiety: "불안함"
        case .satisfied: "만족함"
        case .tired: "피로함"
        }
    }

    var image: UIImage? {
        switch self {
        case .calm: BitnagilGraphic.calmOrb
        case .lethargy: BitnagilGraphic.lethargyOrb
        case .vitality: BitnagilGraphic.vitalityOrb
        case .anxiety: BitnagilGraphic.anxietyOrb
        case .satisfied: BitnagilGraphic.satisfiedOrb
        case .tired: BitnagilGraphic.tiredOrb
        }
    }
}
