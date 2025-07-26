//
//  NetworkError.swift
//  NetworkService
//
//  Created by 최정인 on 6/23/25.
//

enum NetworkError: Error, CustomStringConvertible {
    case invalidURL
    case invalidResponse
    case invalidStatusCode(statusCode: Int)
    case emptyData
    case decodingError

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
        }
    }
}
