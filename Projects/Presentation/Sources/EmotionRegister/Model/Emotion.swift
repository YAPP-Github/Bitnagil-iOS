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
    /// Converts this EmotionEntity into a domain Emotion value.
    /// - Returns: An `Emotion` with fields mapped from the entity (`emotionType` → `emotionType`, `emotionName` → `emotionTitle`, `emotionImageUrl` → `emotionImageUrl`, `emotionMessage` → `emotionMessage`).
    func toEmotion() -> Emotion {
        return Emotion(
            emotionType: emotionType,
            emotionTitle: emotionName,
            emotionImageUrl: emotionImageUrl,
            emotionMessage: emotionMessage)
    }
}
