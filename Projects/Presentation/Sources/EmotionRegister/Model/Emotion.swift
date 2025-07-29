//
//  Emotion.swift
//  Presentation
//
//  Created by 최정인 on 7/29/25.
//

import Domain
import Foundation

struct Emotion {
    let emotionType: String
    let emotionTitle: String
    let emotionImageUrl: URL?
}

extension EmotionEntity {
    func toEmotion() -> Emotion {
        return Emotion(
            emotionType: emtionType,
            emotionTitle: emotionName,
            emotionImageUrl: emotionImageUrl)
    }
}
