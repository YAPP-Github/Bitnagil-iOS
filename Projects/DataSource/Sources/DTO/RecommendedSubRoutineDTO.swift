//
//  RecommendedSubRoutineDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

struct RecommendedSubRoutineDTO: Decodable {
    let id: Int
    let routineName: String

    enum CodingKeys: String, CodingKey {
        case id = "recommendedSubRoutineId"
        case routineName = "recommendedSubRoutineName"
    }
}

extension RecommendedSubRoutineDTO {
    func toRecommendedSubRoutineEntity() -> RecommendedSubRoutineEntity {
        return RecommendedSubRoutineEntity(id: id, title: routineName)
    }
}
