//
//  RecommendedRoutineDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

import Domain

struct RecommendedRoutineListResponseDTO: Decodable {
    let recommendedRoutines: [RecommendedRoutineDTO]
}

struct RecommendedRoutineDTO: Decodable {
    let id: Int
    let routineName: String
    let routineDescription: String
    let subRoutines: [SubRoutine]

    enum CodingKeys: String, CodingKey {
        case id = "recommendedRoutineId"
        case routineName = "recommendedRoutineName"
        case routineDescription
        case subRoutines = "recommendedSubRoutines"
    }

    func toRecommendedRoutineEntity() -> RecommendedRoutineEntity {
        return RecommendedRoutineEntity(
            id: id,
            title: routineName,
            description: routineDescription)
    }
}

struct SubRoutine: Decodable {
    let id: Int
    let routineName: String

    enum CodingKeys: String, CodingKey {
        case id = "recommendedSubRoutineId"
        case routineName = "recommendedSubRoutineName"
    }
}
