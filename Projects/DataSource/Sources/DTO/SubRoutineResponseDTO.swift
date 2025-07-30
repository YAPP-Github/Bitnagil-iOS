//
//  SubRoutineResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

struct SubRoutineResponseDTO: Decodable {
    let subRoutineId: String
    let historySeq: Int
    let subRoutineName: String
    let modifiedYn: Bool
    let sortOrder: Int
    let routineCompletionId: Int?
    let completeYn: Bool
    let routineType: String
}

extension SubRoutineResponseDTO {
    func toSubRoutineEntity() -> SubRoutineEntity {
        return SubRoutineEntity(
            subRoutineId: subRoutineId,
            historySeq: historySeq,
            subRoutineName: subRoutineName,
            modifiedYn: modifiedYn,
            sortOrder: sortOrder,
            routineCompletionId: routineCompletionId,
            completeYn: completeYn,
            routineType: routineType)
    }
}
