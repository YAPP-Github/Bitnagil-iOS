//
//  RoutineCompletionEntity.swift
//  Domain
//
//  Created by 최정인 on 8/6/25.
//

public struct RoutineCompletionEntity {
    public let performedDate: String
    public let routineId: String
    public let completeYn: Bool
    public let historySeq: Int
    public let routineType: String

    public init(
        performedDate: String,
        routineId: String,
        completeYn: Bool,
        historySeq: Int,
        routineType: String
    ) {
        self.performedDate = performedDate
        self.routineId = routineId
        self.completeYn = completeYn
        self.historySeq = historySeq
        self.routineType = routineType
    }
}
