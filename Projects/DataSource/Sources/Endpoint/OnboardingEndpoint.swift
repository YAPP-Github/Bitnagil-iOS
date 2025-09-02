//
//  OnboardingEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/15/25.
//

enum OnboardingEndpoint {
    case loadOnboardingResult
    case registerOnboarding(onboarding: OnboardingDTO)
    case registerRecommendedRoutine(selectedRoutines: [Int])
}

extension OnboardingEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v2/onboardings"
    }

    var path: String {
        switch self {
        case .registerOnboarding, .loadOnboardingResult:
            return baseURL
        case .registerRecommendedRoutine: 
            return baseURL + "/routines"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadOnboardingResult:
            return .get
        case .registerOnboarding, .registerRecommendedRoutine:
            return .post
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
        return [:]
    }
    
    var bodyParameters: [String : Any] {
        switch self {
        case .registerOnboarding(let onboarding):
            return onboarding.dictionary
        case .registerRecommendedRoutine(let selectedRoutines):
            return ["recommendedRoutineIds": selectedRoutines]
        default:
            return [:]
        }
    }

    var isAuthorized: Bool {
        return true
    }
}
