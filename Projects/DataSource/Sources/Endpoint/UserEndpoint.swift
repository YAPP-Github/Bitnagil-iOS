//
//  UserEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 7/30/25.
//

enum UserEndpoint {
    case loadNickname
}

extension UserEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/users/infos"
    }
    
    var path: String {
        return baseURL
    }
    
    var method: HTTPMethod {
        switch self {
        case .loadNickname: .get
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
        return [:]
    }
    
    var isAuthorized: Bool {
        return true
    }
}
