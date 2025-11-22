//
//  Endpoint+.swift
//  NetworkService
//
//  Created by 최정인 on 6/21/25.
//

import Foundation

extension Endpoint {
    func makeURLRequest() throws -> URLRequest {
        var request = try URLRequest(urlString: path, queryParameters: queryParameters)
        request.httpMethod = method.rawValue
        request.makeHeaders(headers: headers)
        switch bodyType {
        case .json:
            try request.makeBodyParameter(with: bodyParameters)
        case .rawData:
            if let data = bodyData {
                request.httpBody = data
            }
        }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        return request
    }
}
