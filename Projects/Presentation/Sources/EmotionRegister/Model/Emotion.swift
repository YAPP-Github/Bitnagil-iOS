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
    let emotionMessage: String?
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
