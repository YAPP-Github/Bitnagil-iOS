//
//  RoutineCompletionDTO.swift
//  DataSource
//
//  Created by 최정인 on 8/6/25.
//

struct RoutineCompletionListDTO: Encodable {
    let routineCompletionInfos: [RoutineCompletionDTO]
}

struct RoutineCompletionDTO: Encodable {
    let routineId: String
    let routineCompleteYn: Bool
    let subRoutineCompleteYn: [Bool]
}
