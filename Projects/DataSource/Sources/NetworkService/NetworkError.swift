//
//  NetworkError.swift
//  NetworkService
//
//  Created by 최정인 on 6/23/25.
//

enum NetworkError: Error, CustomStringConvertible, Comparable {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(statusCode: Int)
    case emptyData
    case decodingError
    case needRetry
    case noRetry
    case unknown(description: String)

    var description: String {
        switch self {
        case .invalidURL:
            return "invalidURL"
        case .invalidResponse:
            return "invalidResponse"
        case .invalidStatusCode(let statusCode):
            return "\(statusCode)"
        case .emptyData:
            return "emptyData"
        case .decodingError:
            return "decodingError"
        case .needRetry:
            return "request need retry"
        case .noRetry:
            return "request don't need retry"
        case .unknown(let description):
            return "unknown error: \(description)"
        }
    }
}
