//
//  SubRoutine.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Domain

struct SubRoutine: Hashable {
    let id: String
    let title: String
    var isDone: Bool
    let sortIndex: Int
}

extension SubRoutineEntity {
    func toSubRoutine() -> SubRoutine {
        return SubRoutine(
            id: subRoutineId,
            title: subRoutineName,
            isDone: completeYn,
            sortIndex: sortOrder)
    }
}
