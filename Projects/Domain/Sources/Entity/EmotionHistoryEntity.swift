//
//  EmotionHistoryEntity.swift
//  Domain
//
//  Created by 최정인 on 7/21/26.
//

public struct EmotionHistoryEntity {
    public let date: String
    public let emotionMarbleType: String
    public let emotionMarbleName: String
    public let imageUrl: String

    public init(
        date: String,
        emotionMarbleType: String,
        emotionMarbleName: String,
        imageUrl: String
    ) {
        self.date = date
        self.emotionMarbleType = emotionMarbleType
        self.emotionMarbleName = emotionMarbleName
        self.imageUrl = imageUrl
    }
}
