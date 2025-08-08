//
//  RoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

public struct RoutineEntity {
    public let routineId: String?
    public let historySeq: Int
    public let routineName: String
    public let repeatDay: [WeekType]
    public let executionTime: String
    public let subRoutineSearchResultDto: [SubRoutineEntity]
    public let modifiedYn: Bool
    public let routineCompletionId: Int?
    public let completeYn: Bool
    public let routineType: String

    public init(
        routineId: String?,
        historySeq: Int,
        routineName: String,
        repeatDay: [String]?,
        executionTime: String,
        subRoutineSearchResultDto: [SubRoutineEntity],
        modifiedYn: Bool,
        routineCompletionId: Int?,
        completeYn: Bool,
        routineType: String
    ) {
        let weekType: [WeekType] = repeatDay?.compactMap(WeekType.init(rawValue:)) ?? []

        self.routineId = routineId
        self.historySeq = historySeq
        self.routineName = routineName
        self.repeatDay = weekType
        self.executionTime = executionTime
        self.subRoutineSearchResultDto = subRoutineSearchResultDto
        self.modifiedYn = modifiedYn
        self.routineCompletionId = routineCompletionId
        self.completeYn = completeYn
        self.routineType = routineType
    }
}
