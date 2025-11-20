//
//  ReportRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol ReportRepositoryProtocol {
    func report(reportEntity: ReportEntity) async

    /// 제보 상세 기록을 조회합니다.
    /// - Parameter reportId: 조회할 제보의 ID
    /// - Returns: 조회된 제보
    func fetchReportDetail(reportId: Int) async throws -> ReportEntity?
}
