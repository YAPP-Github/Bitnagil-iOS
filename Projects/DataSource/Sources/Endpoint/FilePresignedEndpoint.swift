//
//  FilePresignedEndpoint.swift
//  DataSource
//
//  Created by 이동현 on 11/22/25.
//

import Foundation

enum FilePresignedEndpoint {
    case fetchPresignedURL(presignedConditions: [FilePresignedConditionDTO])
}

extension FilePresignedEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .fetchPresignedURL:
            return AppProperties.baseURL + "/api/v2/files"
        }
    }

    var path: String {
        switch self {
        case .fetchPresignedURL:
            return baseURL + "/presigned-urls"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchPresignedURL: .post
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
        case .fetchPresignedURL(let presignedConditions):
            return [:]
        }
    }

    var isAuthorized: Bool {
        return true
    }

    var bodyType: EndpointBodyType {
        return .rawData
    }

    var bodyData: Data? {
        switch self {
        case .fetchPresignedURL(let presignedConditions):
            return try? JSONEncoder().encode(presignedConditions)
        }
    }
}
