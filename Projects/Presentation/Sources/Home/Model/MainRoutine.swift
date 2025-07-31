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
}

extension RoutineEntity {
    func toMainRoutine() -> MainRoutine {
        return MainRoutine(
            id: routineId,
            title: routineName,
            isDone: completeYn,
            startTime: Date.convertToDate(from: executionTime, dateType: .time) ?? Date(),
            repeatDay: repeatDay.compactMap({ Week(rawValue: $0) }),
            subRoutines: subRoutineSearchResultDto.map({ $0.toSubRoutine() }))
    }
}
