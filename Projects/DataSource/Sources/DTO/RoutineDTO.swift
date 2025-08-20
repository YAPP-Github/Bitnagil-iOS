//
//  RoutineDTO.swift
//  DataSource
//
//  Created by 최정인 on 8/19/25.
//

import Domain

struct RoutineDictionaryDTO: Decodable {
    let routines: [String: RoutineDateDTO]
}

struct RoutineDateDTO: Decodable {
    let routineList: [RoutineDTO]
    let allCompleted: Bool
}

struct RoutineDTO: Decodable {
    let routineId: String
    let routineName: String
    let repeatDay: [String]
    let executionTime: String
    let routineCompleteYn: Bool
    let subRoutineNames: [String]
    let subRoutineCompleteYn: [Bool]
    let recommendedRoutineType: String?
    let routineDeletedYn: Bool
    let routineStartDate: String
    let routineEndDate: String

    func toRoutineEntity() -> RoutineEntity {
        return RoutineEntity(
            routineId: routineId,
            routineName: routineName,
            repeatDay: repeatDay,
            executionTime: executionTime,
            routineCompleteYn: routineCompleteYn,
            subRoutineNames: subRoutineNames,
            subRoutineCompleteYn: subRoutineCompleteYn,
            recommendedRoutineType: recommendedRoutineType,
            routineDeletedYn: routineDeletedYn,
            routineStartDate: routineStartDate,
            routineEndDate: routineEndDate)
    }
}
