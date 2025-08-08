//
//  RoutineUseCase.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

import Foundation
import Shared

public final class RoutineUseCase: RoutineUseCaseProtocol {
    private let routineRepository: RoutineRepositoryProtocol

    public init(routineRepository: RoutineRepositoryProtocol) {
        self.routineRepository = routineRepository
    }

    public func fetchRoutine(routineId: String) async throws -> RoutineEntity? {
        let routineEnity = try await routineRepository.fetchRoutine(routineId: routineId)
        return routineEnity
    }

    public func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: [RoutineEntity]] {
        let start = startDate.convertToString(dateType: .yearMonthDate)
        let end = endDate.convertToString(dateType: .yearMonthDate)

        let routineEntities = try await routineRepository.fetchRoutines(from: start, to: end)
        return routineEntities
    }

    public func saveRoutine(
        routineSummary: RoutineSummaryEntity,
        subRoutineSummaries: [SubRoutineSummaryEntity],
        deletedSubRoutineSummaries: [SubRoutineSummaryEntity]
    ) async throws {
        if routineSummary.routineId == nil { // 루틴 아이디가 있으면 수정, 없으면 생성
            try await createRoutine(routineSummary: routineSummary, subRoutinesSummaries: subRoutineSummaries)
        } else {
            try await updateRoutine(
                routineSummary: routineSummary,
                subRoutineSummaries: subRoutineSummaries,
                deletedSubRoutineSummaries: deletedSubRoutineSummaries)
        }
    }

    private func createRoutine(routineSummary: RoutineSummaryEntity, subRoutinesSummaries: [SubRoutineSummaryEntity]) async throws {
        try await routineRepository.createRoutine(routineSummary: routineSummary, subRoutineSummaries: subRoutinesSummaries)
    }

    private func updateRoutine(
        routineSummary: RoutineSummaryEntity,
        subRoutineSummaries: [SubRoutineSummaryEntity],
        deletedSubRoutineSummaries: [SubRoutineSummaryEntity]
    ) async throws {
        let updatedSubRoutines = subRoutineSummaries
            .enumerated()
            .map {
                SubRoutineSummaryEntity(
                    subRoutineId: $1.subRoutineId,
                    subRoutineName: $1.subRoutineName,
                    sortOrder: $0 + 1)
            }
        let deletedSubRoutines = deletedSubRoutineSummaries.map {
            SubRoutineSummaryEntity(
                subRoutineId: $0.subRoutineId,
                subRoutineName: nil,
                sortOrder: nil)
        }
        let finalSubRoutines = updatedSubRoutines + deletedSubRoutines

        try await routineRepository.updateRoutine(routineSummary: routineSummary, subRoutineSummaries: finalSubRoutines)
    }

    public func deleteAllRoutine(routineId: String) async throws {
        try await routineRepository.deleteAllRoutine(routineId: routineId)
    }

    public func deleteDailyRoutine(routine: DeleteRoutineEntity) async throws {
        try await routineRepository.deleteDailyRoutine(routine: routine)
    }

    public func updateRoutineCompletions(routines: [RoutineCompletionEntity]) async throws {
        try await routineRepository.updateRoutineCompletions(routines: routines)
    }
}
