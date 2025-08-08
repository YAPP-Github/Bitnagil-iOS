//
//  RoutineCompletionDTO.swift
//  DataSource
//
//  Created by 최정인 on 8/6/25.
//

struct RoutineCompletionListDTO: Encodable {
    let performedDate: String
    let routineCompletionInfos: [RoutineCompletionDTO]
}

struct RoutineCompletionDTO: Encodable {
    let routineId: String
    let completeYn: Bool
    let historySeq: Int
    let routineType: String
}
