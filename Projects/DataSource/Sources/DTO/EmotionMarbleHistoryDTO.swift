//
//  EmotionMarbleHistoryDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/21/26.
//

import Domain

struct EmotionMarbleHistoryDTO: Decodable {
    let date: String
    let emotionMarbleType: String
    let emotionMarbleName: String
    let imageUrl: String

    func toEmotionHistoryEntity() -> EmotionHistoryEntity {
        return EmotionHistoryEntity(
            date: date,
            emotionMarbleType: emotionMarbleType,
            emotionMarbleName: emotionMarbleName,
            imageUrl: imageUrl)
    }
}
