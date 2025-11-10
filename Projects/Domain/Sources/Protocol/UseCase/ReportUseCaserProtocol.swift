//
//  ReportUseCaserProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol ReportUseCaserProtocol {
    func getCurrentLocation() async throws -> LocationEntity?

    func report(reportEntity: ReportEntity) async
}
