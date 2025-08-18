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
    let routineType: String
    let subRoutines: [RecommendedSubRoutineDTO]

    enum CodingKeys: String, CodingKey {
        case id = "recommendedRoutineId"
        case routineName = "recommendedRoutineName"
        case routineDescription = "recommendedRoutineDescription"
        case routineLevel = "recommendedRoutineLevel"
        case routineType = "recommendedRoutineType"
        case subRoutines = "recommendedSubRoutineSearchResult"
    }
}

extension RecommendedRoutineDTO {
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
            type: RoutineCategoryType(rawValue: routineType) ?? .rest,
            level: level,
            subRoutines: subRoutines.compactMap({ $0.toRecommendedSubRoutineEntity() }))
    }
}
