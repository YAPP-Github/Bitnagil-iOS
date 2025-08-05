//
//  MainRoutine.swift
//  Presentation
//
//  Created by 최정인 on 7/18/25.
//

import Domain
import Foundation

struct MainRoutine {
    let id: String
    let title: String
    var isDone: Bool
    let startTime: Date
    let repeatDay: [Week]
    var subRoutines: [SubRoutine]
    let historySeq: Int
    let completionId: Int?
    let routineType: String
}

extension RoutineEntity {
    func toMainRoutine() -> MainRoutine? {
        guard let routineId else { return nil }

        let subRoutines = subRoutineSearchResultDto.compactMap { $0.toSubRoutine() }
        let isAllConverted = subRoutines.count == subRoutineSearchResultDto.count
        guard isAllConverted else { return nil }

        return MainRoutine(
            id: routineId,
            title: routineName,
            isDone: completeYn,
            startTime: Date.convertToDate(from: executionTime, dateType: .time) ?? Date(),
            repeatDay: repeatDay.compactMap({ Week(rawValue: $0.rawValue) }),
            subRoutines: subRoutines,
            historySeq: historySeq,
            completionId: routineCompletionId,
            routineType: routineType)
    }
}
