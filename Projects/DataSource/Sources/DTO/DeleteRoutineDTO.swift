//
//  DeleteRoutineDTO.swift
//  DataSource
//
//  Created by 최정인 on 8/4/25.
//

struct DeleteRoutineDTO: Encodable {
    let routineId: String
    let routineCompletionId: Int?
    let historySeq: Int
    let routineType: String
    let performedDate: String
    let subRoutineInfosForDelete: [DeleteSubRoutineDTO]
}

struct DeleteSubRoutineDTO: Encodable {
    let subRoutineId: String
    let routineCompletionId: Int?
}
