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
    case logout
    case withdraw
    case reissue(refreshToken: String)
    case agreements(agreements: [TermsType: Bool])
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
        case .reissue(let refreshToken):
            headers["Refresh-Token"] = refreshToken
        default:
            break
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
        case .agreements(let agreements):
            var parameters: [String: Any] = [:]
            for agreement in agreements {
                parameters[agreement.key.termKey] = agreement.value
            }
            return parameters
        default:
            return [:]
        }
    }

    var isAuthorized: Bool {
        switch self {
        case .login, .reissue: false
        case .logout, .withdraw, .agreements: true
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
