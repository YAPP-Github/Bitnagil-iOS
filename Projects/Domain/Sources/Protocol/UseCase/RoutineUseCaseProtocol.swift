//
//  RoutineUseCaseProtocol.swift
//  Domain
//
//  Created by 최정인 on 7/30/25.
//

import Foundation

public protocol RoutineUseCaseProtocol {
    func fetchRoutine(routineId: String) async throws -> RoutineEntity?

    func fetchRoutines(startDate: Date, endDate: Date) async throws -> [String: (routines: [RoutineEntity], allCompleted: Bool)]

    func saveRoutine(routine: RoutineCreationEntity) async throws

    func deleteAllRoutine(routineId: String) async throws

    func deleteDailyRoutine(routineId: String) async throws

    func updateRoutineCompletions(routines: [RoutineCompletionEntity]) async throws
}
