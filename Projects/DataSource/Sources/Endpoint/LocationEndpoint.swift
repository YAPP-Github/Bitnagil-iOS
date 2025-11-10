//
//  LocationEndpoint.swift
//  DataSource
//
//  Created by 이동현 on 11/10/25.
//

enum LocationEndpoint {
    case fetchAddress(longitude: Double, latitude: Double)
}

extension LocationEndpoint: Endpoint {
    var baseURL: String {
        switch self {
        case .fetchAddress:
            "https://dapi.kakao.com/v2"
        }
    }

    var path: String {
        switch self {
        case .fetchAddress:
            return baseURL + "/local/geo/coord2address.json"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .fetchAddress:
            return .get
        }
    }

    var headers: [String : String] {
        let headers: [String: String] = [
            "Authorization": "KakaoAK \(AppProperties.kakaoApiKey)",
        ]
        return headers
    }

    var queryParameters: [String : String] {
        switch self {
        case .fetchAddress(let longitude, let latitude):
            ["x": "\(longitude)", "y": "\(latitude)"]
        }
    }

    var bodyParameters: [String : Any] {
        return [:]
    }

    var isAuthorized: Bool {
        return false
    }
}
