//
//  RoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

final class RoutineRepository: RoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

    func createRoutine(routine: RoutineEntity) async throws {
        let routineCreationDTO = RoutineCreationDTO(
            routineName: routine.routineName,
            repeatDay: routine.repeatDay.map { $0.rawValue },
            executionTime: routine.executionTime,
            subRoutineName: routine.subRoutineSearchResultDto.map { $0.subRoutineName })
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

    func updateRoutine(routine: Domain.RoutineEntity) async throws {
        guard let routineId = routine.routineId else { return }
        
        let subRoutines = routine
            .subRoutineSearchResultDto
            .map {
                SubRoutineUpdateDTO(
                    subRoutineId: $0.subRoutineId ?? "",
                    subRoutineName: $0.subRoutineName,
                    sortOrder: $0.sortOrder)}
        let routineUpdateDTO = RoutineUpdateDTO(
            routineId: routineId,
            routineName: routine.routineName,
            repeatDay: routine.repeatDay.map { $0.rawValue },
            executionTime: routine.executionTime,
            subRoutineInfos: subRoutines)
        let endpoint = RoutineEndpoint.updateRoutine(routine: routineUpdateDTO)
        
        _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
    }
}
