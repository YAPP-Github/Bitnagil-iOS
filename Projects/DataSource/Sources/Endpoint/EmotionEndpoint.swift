//
//  EmotionEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/28/25.
//

enum EmotionEndpoint {
    case fetchEmotions
    case registerEmotion(emotion: String)
}

extension EmotionEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/emotion-marbles"
    }
    
    var path: String {
        return baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchEmotions: .get
        case .registerEmotion: .post
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
        case .fetchEmotions:
            return [:]
        case .registerEmotion(let emotion):
            return ["emotionMarbleType": emotion]
        }
    }
    
    var isAuthorized: Bool {
        return true
    }
}
