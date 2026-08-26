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
    private let analyticsLogger: AnalyticsLoggerProtocol

    public init(routineRepository: RoutineRepositoryProtocol, analyticsLogger: AnalyticsLoggerProtocol) {
        self.routineRepository = routineRepository
        self.analyticsLogger = analyticsLogger
    }

    public func fetchRoutine(routineId: String) async throws -> RoutineEntity? {
        let routineEnity = try await routineRepository.fetchRoutine(routineId: routineId)
        return routineEnity
    }

    public func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: (routines: [RoutineEntity], allCompleted: Bool)] {
        let start = startDate.convertToString(dateType: .yearMonthDate)
        let end = endDate.convertToString(dateType: .yearMonthDate)

        let routineEntities = try await routineRepository.fetchRoutines(from: start, to: end)
        return routineEntities
    }

    public func saveRoutine(routine: RoutineCreationEntity) async throws {
        let routine = RoutineCreationEntity(
            id: routine.id,
            name: routine.name,
            repeatDay: routine.repeatDay,
            startDate: routine.startDate,
            endDate: routine.endDate,
            executionTime: routine.executionTime,
            subroutines: routine.subroutines.filter { !$0.isEmpty },
            recommendedRoutineType: routine.recommendedRoutineType,
            applyDateType: routine.applyDateType)

        if routine.id == nil { // 루틴 아이디가 있으면 수정, 없으면 생성
            try await createRoutine(routine: routine)
        } else {
            try await updateRoutine(routine: routine)
        }
    }

    private func createRoutine(routine: RoutineCreationEntity) async throws {
        try await routineRepository.createRoutine(routine: routine)
    }

    private func updateRoutine(routine: RoutineCreationEntity) async throws {
        try await routineRepository.updateRoutine(routine: routine)
    }

    public func deleteAllRoutine(routineId: String) async throws {
        try await routineRepository.deleteAllRoutine(routineId: routineId)
    }

    public func deleteDailyRoutine(routineId: String) async throws {
        try await routineRepository.deleteDailyRoutine(routineId: routineId)
    }

    public func updateRoutineCompletions(routines: [RoutineEntity]) async throws {
        try await routineRepository.updateRoutineCompletions(routines: routines)

        // 완료 처리된 루틴이 있을 때만 이벤트를 발행합니다. (완료 해제는 제외)
        if routines.contains(where: { $0.routineCompleteYn }) {
            analyticsLogger.log(.routineCompleted)
        }
    }
}
