//
//  EmotionResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/29/25.
//

import Domain
import Foundation

struct EmotionResponseDTO: Decodable {
    let type: String
    let name: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case type = "emotionMarbleType"
        case name = "emotionMarbleName"
        case imageUrl
    }
}

extension EmotionResponseDTO {
    func toEmotionEntity() -> EmotionEntity {
        return EmotionEntity(
            emotionType: type,
            emotionName: name,
            emotionImageUrl: URL(string: imageUrl))
    }
}
