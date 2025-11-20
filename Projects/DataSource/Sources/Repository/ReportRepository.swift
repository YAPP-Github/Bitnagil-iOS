//
//  ReportRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/9/25.
//

import Domain

final class ReportRepository: ReportRepositoryProtocol {
    private let networkService = NetworkService.shared

    func report(reportEntity: ReportEntity) async {

    }

    func fetchReportDetail(reportId: Int) async throws -> ReportEntity? {
        let endpoint = ReportEndpoint.fetchReportDetail(reportId: reportId)
        guard let response = try await networkService.request(endpoint: endpoint, type: ReportDTO.self) else { return nil }
        return try response.toReportEntity()
    }
}
