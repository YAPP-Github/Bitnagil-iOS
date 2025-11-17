//
//  ReportUseCaserProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol ReportUseCaseProtocol {
    func fetchCurrentLocation() async throws -> LocationEntity?

    func report(reportEntity: ReportEntity) async
}
