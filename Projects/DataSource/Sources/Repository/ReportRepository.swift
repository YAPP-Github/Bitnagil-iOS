//
//  ReportRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/9/25.
//

import Domain
import Foundation

final class ReportRepository: ReportRepositoryProtocol {
    private let networkService = NetworkService.shared

    func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photoURLs: [String]
    ) async throws -> Int? {
        let reportDTO = ReportDTO(
            reportId: nil,
            reportDate: nil,
            reportTitle: title,
            reportContent: content,
            reportLocation: location?.address ?? "",
            reportStatus: nil,
            reportCategory: category.description,
            reportImageUrl: nil,
            reportImageUrls: photoURLs,
            latitude: location?.latitude,
            longitude: location?.longitude
        )

        let endpoint = ReportEndpoint.register(report: reportDTO)
        guard let id = try await networkService.request(endpoint: endpoint, type: Int.self) else { return nil }

        return id
    }

    func fetchReports() async throws -> [ReportEntity] {
        let endpoint = ReportEndpoint.fetchReports
        guard let response = try await networkService.request(endpoint: endpoint, type: ReportDictonaryDTO.self)
        else { return [] }

        var reportEntities: [ReportEntity] = []
        for (date, reports) in response.reportInfos {
            let reportHistories = reports.compactMap({ try? $0.toReportEntity(date: date) })
            reportEntities += reportHistories
        }

        return reportEntities
    }

    func fetchReportDetail(reportId: Int) async throws -> ReportEntity? {
        let endpoint = ReportEndpoint.fetchReportDetail(reportId: reportId)
        guard let response = try await networkService.request(endpoint: endpoint, type: ReportDTO.self)
        else { return nil }

        return try response.toReportEntity()
    }
}
