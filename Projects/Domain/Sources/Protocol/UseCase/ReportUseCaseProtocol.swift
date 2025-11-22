//
//  ReportUseCaserProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

public protocol ReportUseCaseProtocol {
    func fetchCurrentLocation() async throws -> LocationEntity?

    func fetchReports() async throws -> [ReportEntity]

    func fetchReport(reportId: Int) async throws -> ReportEntity?

    func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photos: [Data]
    ) async throws
}
