//
//  EmotionEntity.swift
//  Domain
//
//  Created by 최정인 on 7/29/25.
//

import Foundation

public struct EmotionEntity {
    public let emotionType: String
    public let emotionName: String
    public let emotionImageUrl: URL?

    public init(
        emotionType: String,
        emotionName: String,
        emotionImageUrl: URL?
    ) {
        self.emotionType = emotionType
        self.emotionName = emotionName
        self.emotionImageUrl = emotionImageUrl
    }
}
