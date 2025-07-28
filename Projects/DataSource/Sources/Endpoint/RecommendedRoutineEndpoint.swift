//
//  RecommendedRoutineEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/27/25.
//

enum RecommendedRoutineEndpoint {
    case fetchRecommendedRoutines
}

extension RecommendedRoutineEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/recommend-routines"
    }
    
    var path: String {
        switch self {
        case .fetchRecommendedRoutines: baseURL
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: [String : String] {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        return headers
    }
    
    var queryParameters: [String : String] {
        return [:]
    }
    
    var bodyParameters: [String : Any] {
        return [:]
    }
    
    var isAuthorized: Bool {
        return true
    }
}
