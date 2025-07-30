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

    public func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: [RoutineEntity]] {
        let start = startDate.convertToString(dateType: .yearMonthDate)
        let end = endDate.convertToString(dateType: .yearMonthDate)

        var routineEntities = try await routineRepository.fetchRoutines(from: start, to: end)
        return routineEntities
    }
}
