//
//  Routine.swift
//  Presentation
//
//  Created by 최정인 on 8/20/25.
//

import Domain
import Foundation

struct Routine: RoutineProtocol {
    let id: String
    let title: String
    var isDone: Bool
    let startTime: Date
    let repeatDay: [Week]
    var subRoutines: [String]
    var subRoutineCompleted: [Bool]
    let routineType: RoutineCategoryType?
    let isDeleted: Bool
    let startDate: Date
    let endDate: Date
}

extension RoutineEntity {
    func toRoutine() -> Routine {
        return Routine(
            id: routineId,
            title: routineName,
            isDone: routineCompleteYn,
            startTime: Date.convertToDate(from: executionTime, dateType: .time) ?? Date(),
            repeatDay: repeatDay.map({ Week(rawValue: $0) ?? .monday }),
            subRoutines: subRoutineNames,
            subRoutineCompleted: subRoutineCompleteYn,
            routineType: RoutineCategoryType(rawValue: recommendedRoutineType ?? ""),
            isDeleted: routineDeletedYn,
            startDate: Date.convertToDate(from: routineStartDate, dateType: .yearMonthDate) ?? Date(),
            endDate: Date.convertToDate(from: routineEndDate, dateType: .yearMonthDate) ?? Date())
    }
}
