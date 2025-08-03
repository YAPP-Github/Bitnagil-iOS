//
//  RoutineUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

import Foundation

public protocol RoutineUseCaseProtocol {
    func fetchRoutine(routineId: String) async throws -> RoutineEntity?

    func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: [RoutineEntity]]

    func saveRoutine(
        routineSummary: RoutineSummaryEntity,
        subRoutineSummaries: [SubRoutineSummaryEntity],
        deletedSubRoutineSummaries: [SubRoutineSummaryEntity]
    ) async throws
}
