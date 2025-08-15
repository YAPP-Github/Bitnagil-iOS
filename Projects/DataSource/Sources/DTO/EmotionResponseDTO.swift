//
//  EmotionResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/29/25.
//

import Domain
import Foundation

struct EmotionResponseDTO: Decodable {
    let type: String?
    let name: String?
    let imageUrl: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case type = "emotionMarbleType"
        case name = "emotionMarbleName"
        case imageUrl
        case message = "emotionMarbleHomeMessage"
    }
}

extension EmotionResponseDTO {
    /// Converts the DTO into an `EmotionEntity`.
    /// 
    /// Returns `nil` if any of the required DTO fields (`type`, `name`, or `imageUrl`) are missing; otherwise returns an `EmotionEntity` with `emotionType`, `emotionName`, `emotionImageUrl` (constructed from `imageUrl`), and the optional `emotionMessage`.
    /// - Returns: An `EmotionEntity` populated from this DTO, or `nil` when required fields are absent.
    func toEmotionEntity() -> EmotionEntity? {
        guard
            let type,
            let name,
            let imageUrl
        else { return nil }

        return EmotionEntity(
            emotionType: type,
            emotionName: name,
            emotionImageUrl: URL(string: imageUrl),
            emotionMessage: message)
    }
}
