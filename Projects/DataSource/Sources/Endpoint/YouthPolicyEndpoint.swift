//
//  YouthPolicyEndpoint.swift
//  DataSource
//

enum YouthPolicyEndpoint {
    case fetchPolicies(latitude: Double, longitude: Double, cursor: String?, size: Int?)
    case fetchBookmarkedPolicies(cursor: String?, size: Int?)
    case addBookmark(policyNumber: String)
    case removeBookmark(policyNumber: String)
}

extension YouthPolicyEndpoint: Endpoint {
    var baseURL: String {
        return AppProperties.baseURL + "/api/v1/youth-policies"
    }

    var path: String {
        switch self {
        case .fetchPolicies:
            return baseURL
        case .fetchBookmarkedPolicies:
            return "\(baseURL)/bookmarks"
        case .addBookmark(let policyNumber), .removeBookmark(let policyNumber):
            return "\(baseURL)/\(policyNumber)/bookmark"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchPolicies, .fetchBookmarkedPolicies:
            return .get
        case .addBookmark:
            return .post
        case .removeBookmark:
            return .delete
        }
    }

    var headers: [String: String] {
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "accept": "*/*"
        ]
        return headers
    }

    var queryParameters: [String: String] {
        switch self {
        case .fetchPolicies(let latitude, let longitude, let cursor, let size):
            var parameters = [
                "latitude": "\(latitude)",
                "longitude": "\(longitude)"
            ]
            if let cursor { parameters["cursor"] = cursor }
            if let size { parameters["size"] = "\(size)" }
            return parameters
        case .fetchBookmarkedPolicies(let cursor, let size):
            var parameters: [String: String] = [:]
            if let cursor { parameters["cursor"] = cursor }
            if let size { parameters["size"] = "\(size)" }
            return parameters
        case .addBookmark, .removeBookmark:
            return [:]
        }
    }

    var bodyParameters: [String: Any] {
        return [:]
    }

    var isAuthorized: Bool {
        return true
    }
}
