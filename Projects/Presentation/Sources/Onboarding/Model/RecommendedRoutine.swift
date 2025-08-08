//
//  RecommendedRoutine.swift
//  Presentation
//
//  Created by 최정인 on 7/11/25.
//

import Domain

public struct RecommendedRoutine: OnboardingChoiceProtocol, Hashable {
    let id: Int
    let mainTitle: String
    let subTitle: String?
    let routineCategory: RoutineCategoryType
    let routineLevel: RoutineLevelType

    init(
        id: Int,
        mainTitle: String,
        subTitle: String?,
        routineCategory: RoutineCategoryType,
        routineLevel: RoutineLevelType
    ) {
        self.id = id
        self.mainTitle = mainTitle
        self.subTitle = subTitle
        self.routineCategory = routineCategory
        self.routineLevel = routineLevel
    }
}

extension RecommendedRoutineEntity {
    func toRecommendedRoutine() -> RecommendedRoutine {
        return RecommendedRoutine(
            id: id,
            mainTitle: title,
            subTitle: description,
            routineCategory: category ?? .recommendation,
            routineLevel: level ?? .easy
        )
    }
}
