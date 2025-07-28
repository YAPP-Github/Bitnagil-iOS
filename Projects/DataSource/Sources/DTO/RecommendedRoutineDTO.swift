//
//  RecommendedRoutineDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/27/25.
//

import Domain

struct RecommendedRoutineDTO: Decodable {
    let id: Int
    let routineName: String
    let routineDescription: String
    let routineLevel: String?
    let subRoutines: [SubRoutineDTO]

    enum CodingKeys: String, CodingKey {
        case id = "recommendedRoutineId"
        case routineName = "recommendedRoutineName"
        case routineDescription = "recommendedRoutineDescription"
        case routineLevel = "recommendedRoutineLevel"
        case subRoutines = "recommendedSubRoutineSearchResult"
    }

    func toRecommendedRoutineEntity(category: String? = nil) -> RecommendedRoutineEntity {
        var routineCategory: RoutineCategoryType?
        if let category {
            routineCategory = RoutineCategoryType(rawValue: category)
        }

        var level: RoutineLevelType?
        if let routineLevel {
            level = RoutineLevelType(rawValue: routineLevel)
        }
        return RecommendedRoutineEntity(
            id: id,
            title: routineName,
            description: routineDescription,
            category: routineCategory,
            level: level,
            subRoutines: subRoutines.compactMap({ $0.toSubRoutineEntity() }))
    }
}

struct SubRoutineDTO: Decodable {
    let id: Int
    let routineName: String

    enum CodingKeys: String, CodingKey {
        case id = "recommendedSubRoutineId"
        case routineName = "recommendedSubRoutineName"
    }

    func toSubRoutineEntity() -> SubRoutineEntity {
        return SubRoutineEntity(id: id, title: routineName)
    }
}
