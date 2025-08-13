//
//  OnboardingEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

enum OnboardingEndpoint {
    case registerOnboarding(choices: [String: String])
    case registerRecommendedRoutine(selectedRoutines: [Int])
}

extension OnboardingEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .registerOnboarding:
            return AppProperties.baseURL + "/api/v1/onboardings"
        case .registerRecommendedRoutine:
            return AppProperties.baseURL + "/api/v2/onboardings"
        }
    }

    var path: String {
        switch self {
        case .registerOnboarding: baseURL
        case .registerRecommendedRoutine: baseURL + "/routines"
        }
    }
    
    var method: HTTPMethod {
        return .post
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
        switch self {
        case .registerOnboarding(let choices):
            return choices
        case .registerRecommendedRoutine(let selectedRoutines):
            return ["recommendedRoutineIds": selectedRoutines]
        }
    }

    var isAuthorized: Bool {
        return true
    }
}
