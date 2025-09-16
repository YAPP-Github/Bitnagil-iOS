//
//  RecommendedRoutine.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import Domain

public struct RecommendedRoutine: BitnagilChoiceProtocol, RoutineProtocol, Hashable {
    let id: Int
    let title: String
    let subTitle: String?
    let subRoutines: [String]
    let routineCategory: RoutineCategoryType
    let routineType: RoutineCategoryType?
    let routineLevel: RoutineLevelType

    init(
        id: Int,
        mainTitle: String,
        subTitle: String?,
        subRoutines: [String],
        routineCategory: RoutineCategoryType,
        routineType: RoutineCategoryType,
        routineLevel: RoutineLevelType
    ) {
        self.id = id
        self.title = mainTitle
        self.subTitle = subTitle
        self.subRoutines = subRoutines
        self.routineCategory = routineCategory
        self.routineType = routineType
        self.routineLevel = routineLevel
    }
}

extension RecommendedRoutineEntity {
    func toRecommendedRoutine() -> RecommendedRoutine {
        return RecommendedRoutine(
            id: id,
            mainTitle: title,
            subTitle: description,
            subRoutines: subRoutines.map({ $0.title }),
            routineCategory: category ?? .recommendation,
            routineType: type ?? .recommendation,
            routineLevel: level ?? .easy
        )
    }
}
