//
//  SubRoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

public struct SubRoutineEntity: Decodable {
    public let subRoutineId: String?
    public let historySeq: Int
    public let subRoutineName: String
    public let modifiedYn: Bool
    public let sortOrder: Int
    public let routineCompletionId: Int?
    public let completeYn: Bool
    public let routineType: String

    public init(
        subRoutineId: String,
        historySeq: Int,
        subRoutineName: String,
        modifiedYn: Bool,
        sortOrder: Int,
        routineCompletionId: Int?,
        completeYn: Bool,
        routineType: String
    ) {
        self.subRoutineId = subRoutineId
        self.historySeq = historySeq
        self.subRoutineName = subRoutineName
        self.modifiedYn = modifiedYn
        self.sortOrder = sortOrder
        self.routineCompletionId = routineCompletionId
        self.completeYn = completeYn
        self.routineType = routineType
    }
}
