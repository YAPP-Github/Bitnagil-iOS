//
//  S3UploadEndpoint.swift
//  DataSource
//
//  Created by 이동현 on 11/22/25.
//

import Foundation

enum S3Endpoint {
    case uploadImage(uploadURL: String, data: Data)
}

extension S3Endpoint: Endpoint {
    var baseURL: String {
        return ""
    }
    
    var path: String {
        switch self {
        case .uploadImage(let uploadURL, _):
            return uploadURL
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadImage:
            return .put
        }
    }
    
    var headers: [String : String] {
        switch self {
        case .uploadImage:
            return [:]
        }
    }
    
    var queryParameters: [String : String] {
        
        return [:]
    }
    
    var bodyParameters: [String : Any] {
        return [:]
    }
    
    var isAuthorized: Bool {
        return false
    }
    
    var bodyType: EndpointBodyType {
        return .rawData
    }
    
    var bodyData: Data? {
        switch self {
        case .uploadImage(_, let data):
            return data
        }
    }
}
