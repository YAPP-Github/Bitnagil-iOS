//
//  KakaoLocationResponseDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/10/25.
//

import Domain
import Foundation

struct KakaoLocationResponseDTO: Codable {
    let meta: Meta
    let documents: [Document]

    struct Meta: Codable {
        let totalCount: Int
        let pageableCount: Int?
        let isEnd: Bool?

        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case pageableCount = "pageable_count"
            case isEnd = "is_end"
        }
    }
}

// MARK: - Document
struct Document: Codable {
    let roadAddress: KakaoRoadAddress?
    let address: KakaoAddress?

    let addressName: String?
    let y: String? // 위도 (latitude)
    let x: String? // 경도 (longitude)
    let addressType: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case y, x
        case addressType = "address_type"
        case address
        case roadAddress = "road_address"
    }

    var latitude: Double?  {
        if let y, let v = Double(y) { return v }
        if let v = address?.latitude { return v }
        if let v = roadAddress?.latitude { return v }
        return nil
    }

    var longitude: Double? {
        if let x, let v = Double(x) { return v }
        if let v = address?.longitude { return v }
        if let v = roadAddress?.longitude { return v }
        return nil
    }
}

// MARK: - KakaoRoadAddress (도로명 주소)
struct KakaoRoadAddress: Codable {
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let roadName: String
    let undergroundYn: String?
    let mainBuildingNo: String?
    let subBuildingNo: String?
    let buildingName: String?
    let zoneNo: String?
    let y: String?
    let x: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case roadName = "road_name"
        case undergroundYn = "underground_yn"
        case mainBuildingNo = "main_building_no"
        case subBuildingNo = "sub_building_no"
        case buildingName = "building_name"
        case zoneNo = "zone_no"
        case y, x
    }

    var latitude: Double?  { y.flatMap(Double.init) }
    var longitude: Double? { x.flatMap(Double.init) }
}

// MARK: - Address (지번 주소)
struct KakaoAddress: Codable {
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let region3depthHName: String?
    let hCode: String?
    let bCode: String?
    let mountainYn: String?
    let mainAddressNo: String?
    let subAddressNo: String?
    let x: String?
    let y: String?
    let zipCode: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case region3depthHName = "region_3depth_h_name"
        case hCode = "h_code"
        case bCode = "b_code"
        case mountainYn = "mountain_yn"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
        case x, y
        case zipCode = "zip_code"
    }

    var latitude: Double?  { y.flatMap(Double.init) }
    var longitude: Double? { x.flatMap(Double.init) }
}

// MARK: - Mapping
extension KakaoLocationResponseDTO {
    func toLocationEntity(fallbackLongitude: Double? = nil, fallbackLatitude: Double? = nil) -> LocationEntity? {
        guard let doc = documents.first else { return nil }
        let longitude = doc.longitude ?? fallbackLongitude
        let latitude = doc.latitude  ?? fallbackLatitude
        let address = doc.roadAddress?.addressName ?? doc.address?.addressName

        return LocationEntity(longitude: longitude ?? 0, latitude: latitude ?? 0, address: address)
    }
}
