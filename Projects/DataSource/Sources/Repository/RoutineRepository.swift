//
//  RoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

final class RoutineRepository: RoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

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
}
