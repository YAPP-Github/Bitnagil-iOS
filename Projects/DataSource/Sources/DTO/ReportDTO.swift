//
//  ReportDTO.swift
//  DataSource
//
//  Created by 최정인 on 11/20/25.
//

import Domain

struct ReportDTO: Codable {
    let reportId: Int?
    let reportDate: String?
    let reportTitle: String
    let reportContent: String?
    let reportLocation: String
    let reportStatus: String?
    let reportCategory: String
    let reportImageUrl: String?
    let reportImageUrls: [String]?
    let latitude: Double?
    let longitude: Double?

    func toReportEntity() throws -> ReportEntity {
        return ReportEntity(
            id: reportId,
            title: reportTitle,
            date: reportDate,
            type: ReportType(rawValue: reportCategory) ?? .transportation,
            progress: ReportProgress(rawValue: reportStatus ?? "") ?? .received,
            content: reportContent,
            location: LocationEntity(
                longitude: longitude,
                latitude: latitude,
                address: reportLocation),
            thumbnailURL: reportImageUrl,
            photoUrls: reportImageUrls ?? [])
    }

    func toReportEntity(date: String) throws -> ReportEntity {
        guard let reportId else { throw NetworkError.decodingError }
        return ReportEntity(
            id: reportId,
            title: reportTitle,
            date: date,
            type: ReportType(rawValue: reportCategory) ?? .transportation,
            progress: ReportProgress(rawValue: reportStatus ?? "") ?? .received,
            content: reportContent,
            location: LocationEntity(
                longitude: longitude,
                latitude: latitude,
                address: reportLocation),
            thumbnailURL: reportImageUrl,
            photoUrls: reportImageUrls ?? [])
    }
}
