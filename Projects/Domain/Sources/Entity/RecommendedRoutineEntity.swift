//
//  RecommendedRoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 7/15/25.
//

public struct RecommendedRoutineEntity {
    public let id: Int
    public let title: String
    public let description: String
    public let category: RoutineCategoryType?
    public let level: RoutineLevelType?
    public let subRoutines: [RecommendedSubRoutineEntity]

    public init(
        id: Int,
        title: String,
        description: String,
        category: RoutineCategoryType?,
        level: RoutineLevelType?,
        subRoutines: [RecommendedSubRoutineEntity]
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.level = level
        self.subRoutines = subRoutines
    }
}

public struct RecommendedSubRoutineEntity {
    public let id: Int
    public let title: String

    public init(id: Int, title: String) {
        self.id = id
        self.title = title
    }
}
