//
//  ReportRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol ReportRepositoryProtocol {
    func report(reportEntity: ReportEntity) async

    /// 제보 목록을 조회합니다.
    /// - Returns: 조회된 제보 목록
    func fetchReports() async throws -> [ReportEntity]

    /// 제보 상세 기록을 조회합니다.
    /// - Parameter reportId: 조회할 제보의 ID
    /// - Returns: 조회된 제보
    func fetchReportDetail(reportId: Int) async throws -> ReportEntity?
}
