//
//  Endpoint.swift
//  DataSource
//
//  Created by 최정인 on 6/21/25.
//

import Foundation

public protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
    var bodyParameters: [String: Any] { get }
    var isAuthorized: Bool { get }
    var bodyType: EndpointBodyType { get }
    var bodyData: Data? { get }
}

extension Endpoint {
    var bodyType: EndpointBodyType { return .json }
    var bodyData: Data? { return nil }
}
