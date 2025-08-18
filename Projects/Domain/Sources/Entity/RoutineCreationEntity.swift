//
//  RoutineCreationEntity.swift
//  Domain
//
//  Created by 이동현 on 8/18/25.
//
import Foundation


public struct RoutineCreationEntity {
    public let id: String?
    public let name: String
    public let repeatDay: [Week]
    public let startDate: String
    public let endDate: String
    public let executionTime: String
    public let subroutines: [String]
    public let recommendedRoutineType: RoutineCategoryType?
    public let applyDateType: RoutineUpdateApplyDateType?

    public init(
        id: String?,
        name: String,
        repeatDay: [Week],
        startDate: String,
        endDate: String,
        executionTime: String,
        subroutines: [String],
        recommendedRoutineType: RoutineCategoryType?,
        applyDateType: RoutineUpdateApplyDateType?
    ) {
        self.id = id
        self.name = name
        self.repeatDay = repeatDay
        self.startDate = startDate
        self.endDate = endDate
        self.executionTime = executionTime
        self.subroutines = subroutines
        self.recommendedRoutineType = recommendedRoutineType
        self.applyDateType = applyDateType
    }
}
