//
//  RoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

final class RoutineRepository: RoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

    func createRoutine(routineSummary: RoutineSummaryEntity, subRoutineSummaries: [SubRoutineSummaryEntity]) async throws {
        let subRoutineNames = subRoutineSummaries.compactMap { $0.subRoutineName }

        let routineCreationDTO = RoutineCreationDTO(
            routineName: routineSummary.routineName,
            repeatDay: routineSummary.repeatDay.map { $0.rawValue },
            executionTime: routineSummary.executionTime,
            subRoutineName: subRoutineNames)
        let endpoint = RoutineEndpoint.createRoutine(routine: routineCreationDTO)

        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }
    
    func fetchRoutine(routineId: String) async throws -> RoutineEntity? {
        let endpoint = RoutineEndpoint.fetchRoutine(routineId: routineId)
        guard let response = try await networkService.request(endpoint: endpoint, type: RoutineResponseDTO.self) else { return nil }
        
        return response.toRoutineEntity()
    }

    func fetchRoutines(from startDate: String, to endDate: String) async throws -> [String: [RoutineEntity]] {
        let endpoint = RoutineEndpoint.fetchRoutines(startDate: startDate, endDate: endDate)
        guard let response = try await networkService.request(endpoint: endpoint, type: RoutineDictionaryDTO.self)
        else { return [:] }

        var result: [String: [RoutineEntity]] = [:]
        for (date, routineDTO) in response.routines {
            result[date] = routineDTO.compactMap({ $0.toRoutineEntity() })
        }
        return result
    }

    func updateRoutine(routineSummary: RoutineSummaryEntity, subRoutineSummaries: [SubRoutineSummaryEntity]) async throws {
        guard let routineId = routineSummary.routineId else { return }

        let subRoutineDTO = subRoutineSummaries.map {
            SubRoutineUpdateDTO(
                subRoutineId: $0.subRoutineId,
                subRoutineName: $0.subRoutineName,
                sortOrder: $0.sortOrder)
        }

        let routineUpdateDTO = RoutineUpdateDTO(
            routineId: routineId,
            routineName: routineSummary.routineName,
            repeatDay: routineSummary.repeatDay.map { $0.rawValue },
            executionTime: routineSummary.executionTime,
            subRoutineInfos: subRoutineDTO)
        let endpoint = RoutineEndpoint.updateRoutine(routine: routineUpdateDTO)

        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    func deleteAllRoutine(routineId: String) async throws {
        let endpoint = RoutineEndpoint.deleteAllRoutine(routineId: routineId)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    func deleteDailyRoutine(routine: DeleteRoutineEntity) async throws {
        let deleteSubRoutineDTO = routine
            .subRoutineInfosForDelete
            .map({ DeleteSubRoutineDTO(subRoutineId: $0.subRoutineId, routineCompletionId: $0.routineCompletionId) })

        let deleteRoutineDTO = DeleteRoutineDTO(
            routineId: routine.routineId,
            routineCompletionId: routine.routineCompletionId,
            historySeq: routine.historySeq,
            routineType: routine.routineType,
            performedDate: routine.performedDate,
            subRoutineInfosForDelete: deleteSubRoutineDTO)

        let endpoint = RoutineEndpoint.deleteDailyRoutine(routine: deleteRoutineDTO)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }

    func updateRoutineCompletions(routines: [RoutineCompletionEntity]) async throws {
        guard let routine = routines.first else { return }
        let performedDate = routine.performedDate
        let completionDTO = routines.map({ RoutineCompletionDTO(
            routineId: $0.routineId,
            completeYn: $0.completeYn,
            historySeq: $0.historySeq,
            routineType: $0.routineType) })

        let completionListDTO = RoutineCompletionListDTO(
            performedDate: performedDate,
            routineCompletionInfos: completionDTO)

        let endpoint = RoutineEndpoint.updateRoutineCompletion(routines: completionListDTO)
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }
}
