//
//  RoutineSummaryEntity.swift
//  Domain
//
//  Created by 이동현 on 8/3/25.
//

public struct RoutineSummaryEntity {
    public let routineId: String?
    public let routineName: String
    public let repeatDay: [WeekType]
    public let executionTime: String

    public init(
        routineId: String?,
        routineName: String,
        repeatDay: [String]?,
        executionTime: String
    ) {
        let weekType: [WeekType] = repeatDay?.compactMap(WeekType.init(rawValue:)) ?? []

        self.routineId = routineId
        self.routineName = routineName
        self.repeatDay = weekType
        self.executionTime = executionTime
    }
}
