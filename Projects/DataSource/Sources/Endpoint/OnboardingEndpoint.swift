//
//  OnboardingEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

import Foundation

enum OnboardingEndpoint {
    case registerOnboarding(accessToken: String, choices: [String: String])
    case registerRecommendedRoutine(accessToken: String, selectedRoutines: [Int])
}

extension OnboardingEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/onboardings"
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
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]

        switch self {
        case .registerOnboarding(let accessToken, _):
            headers["Authorization"] = "Bearer \(accessToken)"
        case .registerRecommendedRoutine(let accessToken, _):
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
    
    var queryParameters: [String : String] {
        return [:]
    }
    
    var bodyParameters: [String : Any] {
        switch self {
        case .registerOnboarding(_, let choices):
            return choices
        case .registerRecommendedRoutine(_, let selectedRoutines):
            return ["recommendedRoutineIds": selectedRoutines]
        }
    }
}
