//
//  DeleteRoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 8/4/25.
//

public struct DeleteRoutineEntity: Encodable {
    public let routineId: String
    public let routineCompletionId: Int?
    public let historySeq: Int
    public let performedDate: String
    public let routineType: String
    public let subRoutineInfosForDelete: [DeleteSubRoutineEntity]

    public init(
        routineId: String,
        routineCompletionId: Int?,
        historySeq: Int,
        performedDate: String,
        routineType: String,
        subRoutineInfosForDelete: [DeleteSubRoutineEntity]
    ) {
        self.routineId = routineId
        self.routineCompletionId = routineCompletionId
        self.historySeq = historySeq
        self.performedDate = performedDate
        self.routineType = routineType
        self.subRoutineInfosForDelete = subRoutineInfosForDelete
    }
}

public struct DeleteSubRoutineEntity: Encodable {
    public let subRoutineId: String
    public let routineCompletionId: Int?

    public init(subRoutineId: String, routineCompletionId: Int?) {
        self.subRoutineId = subRoutineId
        self.routineCompletionId = routineCompletionId
    }
}
