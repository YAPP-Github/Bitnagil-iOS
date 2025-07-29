//
//  EmotionEntity.swift
//  Domain
//
//  Created by 최정인 on 7/29/25.
//

import Foundation

public struct EmotionEntity {
    public let emtionType: String
    public let emotionName: String
    public let emotionImageUrl: URL?

    public init(
        emtionType: String,
        emotionName: String,
        emotionImageUrl: URL?
    ) {
        self.emtionType = emtionType
        self.emotionName = emotionName
        self.emotionImageUrl = emotionImageUrl
    }
}
