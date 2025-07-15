//
//  AuthEndpoint.swift
//  DataSource
//
//  Created by 최정인 on 6/30/25.
//

import Foundation
import Domain

enum AuthEndpoint {
    case login(socialLoginType: SocialLoginType, nickname: String?, token: String)
    case logout(accessToken: String)
    case withdraw(accessToken: String)
    case reissue(refreshToken: String)
    case agreements(accessToken: String, agreements: [TermsType: Bool])
}

extension AuthEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/auth"
    }
    
    var path: String {
        switch self {
        case .login: baseURL + "/login"
        case .logout: baseURL + "/logout"
        case .withdraw: baseURL + "/withdrawal"
        case .reissue: baseURL + "/token/reissue"
        case .agreements: baseURL + "/agreements"
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
        case .login(_, _, let token):
            headers["SocialAccessToken"] = token
        case .logout(let accessToken):
            headers["Authorization"] = "Bearer \(accessToken)"
        case .withdraw(let accessToken):
            headers["Authorization"] = "Bearer \(accessToken)"
        case .reissue(let refreshToken):
            headers["Refresh-Token"] = refreshToken
        case .agreements(let accessToken, _):
            headers["Authorization"] = "Bearer \(accessToken)"
        }

        return headers
    }
    
    var queryParameters: [String : String] {
        return [:]
    }
    
    var bodyParameters: [String : Any] {
        switch self {
        case .login(let socialLoginType, let nickname, _):
            var parameters = ["socialType": socialLoginType.rawValue]
            if let nickname {
                parameters["nickname"] = nickname
            }
            return parameters
        case .agreements(_, let agreements):
            var parameters: [String: Any] = [:]
            for agreement in agreements {
                parameters[agreement.key.termKey] = agreement.value
            }
            return parameters
        default:
            return [:]
        }
    }
}

extension TermsType {
    var termKey: String {
        switch self {
        case .service: "agreedToTermsOfService"
        case .privacy: "agreedToPrivacyPolicy"
        case .age: "isOverFourteen"
        }
    }
}
