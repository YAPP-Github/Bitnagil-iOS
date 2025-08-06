//
//  SubRoutine.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Domain

struct SubRoutine: Hashable, Routine {
    let id: String
    let title: String
    var isDone: Bool
    let sortIndex: Int
    let completionId: Int?
    let routineType: String
    let historySeq: Int
}

extension SubRoutineEntity {
    func toSubRoutine() -> SubRoutine? {
        guard let subRoutineId else { return nil }

        return SubRoutine(
            id: subRoutineId,
            title: subRoutineName,
            isDone: completeYn,
            sortIndex: sortOrder,
            completionId: routineCompletionId,
            routineType: routineType,
            historySeq: historySeq)
    }
}
