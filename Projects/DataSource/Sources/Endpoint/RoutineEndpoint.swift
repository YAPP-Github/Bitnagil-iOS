//
//  RoutineEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

enum RoutineEndpoint {
    case fetchRoutines(startDate: String, endDate: String)
}

extension RoutineEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/routines"
    }

    var path: String {
        switch self {
        case .fetchRoutines: baseURL
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchRoutines: .get
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
        }
    }
    
    var bodyParameters: [String : Any] {
        return [:]
    }
    
    var isAuthorized: Bool {
        return true
    }
}
