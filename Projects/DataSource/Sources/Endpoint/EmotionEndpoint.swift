//
//  EmotionEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/28/25.
//

enum EmotionEndpoint {
    case fetchEmotions
    case loadEmotion(date: String)
    case registerEmotion(emotion: String)
}

extension EmotionEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .fetchEmotions, .registerEmotion:
            return AppProperties.baseURL + "/api/v1/emotion-marbles"
        case .loadEmotion:
            return AppProperties.baseURL + "/api/v2/emotion-marbles"
        }
    }
    
    var path: String {
        switch self {
        case .fetchEmotions:
            return baseURL
        case .loadEmotion(let date):
            return baseURL + "/\(date)"
        case .registerEmotion:
            return baseURL
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchEmotions: .get
        case .loadEmotion: .get
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
        case .loadEmotion:
            return [:]
        case .registerEmotion(let emotion):
            return ["emotionMarbleType": emotion]
        }
    }
    
    var isAuthorized: Bool {
        return true
    }
}
