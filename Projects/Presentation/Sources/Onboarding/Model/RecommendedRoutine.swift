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

    init(
        id: Int,
        mainTitle: String,
        subTitle: String?,
        routineCategory: RoutineCategoryType = .recommendation
    ) {
        self.id = id
        self.mainTitle = mainTitle
        self.subTitle = subTitle
        self.routineCategory = routineCategory
    }
}

extension RecommendedRoutineEntity {
    func toRecommendedRoutine() -> RecommendedRoutine {
        return RecommendedRoutine(
            id: id,
            mainTitle: title,
            subTitle: description)
    }
}
