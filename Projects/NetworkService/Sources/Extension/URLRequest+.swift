//
//  URLRequest+.swift
//  NetworkService
//
//  Created by 최정인 on 6/21/25.
//

import Foundation

extension URLRequest {
    init(urlString: String, queryParameters: [String: String]) throws {
        guard var components = URLComponents(string: urlString) else {
            throw NetworkError.invalidURL
        }

        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        self.init(url: url)
    }

    mutating func makeHeaders(headers: [String: String]) {
        for header in headers {
            addValue(header.value, forHTTPHeaderField: header.key)
        }
    }

    mutating func makeBodyParameter(with parameters: [String: Any]) throws {
        if parameters.isEmpty { return }
        httpBody = try JSONSerialization.data(withJSONObject: parameters)
    }
}
