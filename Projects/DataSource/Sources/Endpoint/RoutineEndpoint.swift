//
//  RoutineEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

enum RoutineEndpoint {
    case createRoutine(routine: RoutineCreationDTO)
    case fetchRoutine(routineId: String)
    case fetchRoutines(startDate: String, endDate: String)
    case updateRoutine(routine: RoutineCreationDTO)
    case deleteAllRoutine(routineId: String)
    case deleteDailyRoutine(routine: DeleteRoutineDTO)
    case updateRoutineCompletion(routines: RoutineCompletionListDTO)
}

extension RoutineEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .createRoutine, .updateRoutine:
            return AppProperties.baseURL + "/api/v2/routines"
        default:
            return AppProperties.baseURL + "/api/v1/routines"
        }
    }

    var path: String {
        switch self {
        case .fetchRoutine(let routineId):
            "\(baseURL)/\(routineId)"
        case .deleteAllRoutine(let routineId):
            "\(baseURL)/\(routineId)"
        case .deleteDailyRoutine:
            "\(baseURL)/day"
        case .updateRoutineCompletion:
            "\(baseURL)/completions"
        default:
            baseURL
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .createRoutine, .updateRoutineCompletion:
                .post
        case .fetchRoutine, .fetchRoutines:
                .get
        case .updateRoutine:
                .patch
        case .deleteAllRoutine, .deleteDailyRoutine:
                .delete
        }
    }
    
    var headers: [String : String] {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        return headers
    }
    
    var queryParameters: [String : String] {
        switch self {
        case .fetchRoutines(let startDate, let endDate):
            return [
                "startDate": startDate,
                "endDate": endDate]
        default:
            return [:]
        }
    }
    
    var bodyParameters: [String : Any] {
        switch self {
        case .createRoutine(let routine):
            return routine.dictionary
        case .updateRoutine(let routine):
            return routine.dictionary
        case .deleteDailyRoutine(let routine):
            return routine.dictionary
        case .updateRoutineCompletion(let routines):
            return routines.dictionary
        default:
            return [:]
        }
    }
    
    var isAuthorized: Bool {
        return true
    }
}
