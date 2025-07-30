//
//  RoutineResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

struct RoutineDictionaryDTO: Decodable {
    let routines: [String: [RoutineResponseDTO]]
}

struct RoutineResponseDTO: Decodable {
    let routineId: String
    let historySeq: Int
    let routineName: String
    let repeatDay: [String]?
    let executionTime: String
    let subRoutineSearchResultDto: [SubRoutineResponseDTO]
    let modifiedYn: Bool
    let routineCompletionId: Int?
    let completeYn: Bool
    let routineType: String
}

extension RoutineResponseDTO {
    func toRoutineEntity() -> RoutineEntity {
        return RoutineEntity(
            routineId: routineId,
            historySeq: historySeq,
            routineName: routineName,
            repeatDay: repeatDay,
            executionTime: executionTime,
            subRoutineSearchResultDto: subRoutineSearchResultDto.map({ $0.toSubRoutineEntity() }),
            modifiedYn: modifiedYn,
            routineCompletionId: routineCompletionId,
            completeYn: completeYn,
            routineType: routineType)
    }
}
