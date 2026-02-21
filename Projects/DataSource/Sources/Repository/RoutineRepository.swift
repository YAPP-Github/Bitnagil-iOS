//
//  RoutineRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

import Domain

final class RoutineRepository: RoutineRepositoryProtocol {
    private let networkService = NetworkService.shared

    func createRoutine(routine: RoutineCreationEntity) async throws {
        let routineCreationDTO = RoutineCreationDTO(
            routineId: nil,
            updateApplyDate: routine.applyDateType?.rawValue,
            routineName: routine.name,
            repeatDay: routine.repeatDay.map { $0.rawValue },
            routineStartDate: routine.startDate,
            routineEndDate: routine.endDate,
            executionTime: routine.executionTime,
            subRoutineName: routine.subroutines,
            recommendedRoutineType: routine.recommendedRoutineType?.rawValue)

        let endpoint = RoutineEndpoint.createRoutine(routine: routineCreationDTO)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func fetchRoutine(routineId: String) async throws -> RoutineEntity? {
        let endpoint = RoutineEndpoint.fetchRoutine(routineId: routineId)

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: RoutineDTO.self) else { return nil }

            return response.toRoutineEntity()
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func fetchRoutines(from startDate: String, to endDate: String) async throws -> [String: (routines: [RoutineEntity], allCompleted: Bool)] {
        let endpoint = RoutineEndpoint.fetchRoutines(startDate: startDate, endDate: endDate)

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: RoutineDictionaryDTO.self)
            else { return [:] }

            var result: [String: ([RoutineEntity], Bool)] = [:]
            for (date, routineDTO) in response.routines {
                let allCompleted = routineDTO.allCompleted
                let routines = routineDTO.routineList.compactMap({ $0.toRoutineEntity() })
                result[date] = (routines, allCompleted)
            }
            return result
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }
    
    func updateRoutine(routine: RoutineCreationEntity) async throws {
        let routineUpdateDTO = RoutineCreationDTO(
            routineId: routine.id,
            updateApplyDate: routine.applyDateType?.rawValue,
            routineName: routine.name,
            repeatDay: routine.repeatDay.map { $0.rawValue },
            routineStartDate: routine.startDate,
            routineEndDate: routine.endDate,
            executionTime: routine.executionTime,
            subRoutineName: routine.subroutines,
            recommendedRoutineType: routine.recommendedRoutineType?.rawValue)
        let endpoint = RoutineEndpoint.updateRoutine(routine: routineUpdateDTO)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func deleteAllRoutine(routineId: String) async throws {
        let endpoint = RoutineEndpoint.deleteAllRoutine(routineId: routineId)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func deleteDailyRoutine(routineId: String) async throws {
        let endpoint = RoutineEndpoint.deleteDailyRoutine(routineId: routineId)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func updateRoutineCompletions(routines: [RoutineEntity]) async throws {
        let completionDTO = routines.map({ RoutineCompletionDTO(
            routineId: $0.routineId,
            routineCompleteYn: $0.routineCompleteYn,
            subRoutineCompleteYn: $0.subRoutineCompleteYn) })
        let completionListDTO = RoutineCompletionListDTO(routineCompletionInfos: completionDTO)

        let endpoint = RoutineEndpoint.updateRoutineCompletion(routines: completionListDTO)

        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }
}
