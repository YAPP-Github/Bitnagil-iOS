//
//  RoutineEntity.swift
//  Domain
//
//  Created by 최정인 on 8/19/25.
//

public struct RoutineEntity {
    public let routineId: String
    public let routineName: String
    public let repeatDay: [String]
    public let executionTime: String
    public let routineCompleteYn: Bool
    public let subRoutineNames: [String]
    public let subRoutineCompleteYn: [Bool]
    public let recommendedRoutineType: String?
    public let routineDeletedYn: Bool
    public let routineStartDate: String
    public let routineEndDate: String

    public init(
        routineId: String,
        routineName: String,
        repeatDay: [String],
        executionTime: String,
        routineCompleteYn: Bool,
        subRoutineNames: [String],
        subRoutineCompleteYn: [Bool],
        recommendedRoutineType: String?,
        routineDeletedYn: Bool,
        routineStartDate: String,
        routineEndDate: String
    ) {
        self.routineId = routineId
        self.routineName = routineName
        self.repeatDay = repeatDay
        self.executionTime = executionTime
        self.routineCompleteYn = routineCompleteYn
        self.subRoutineNames = subRoutineNames
        self.subRoutineCompleteYn = subRoutineCompleteYn
        self.recommendedRoutineType = recommendedRoutineType
        self.routineDeletedYn = routineDeletedYn
        self.routineStartDate = routineStartDate
        self.routineEndDate = routineEndDate
    }
}
