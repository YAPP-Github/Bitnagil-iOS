//
//  ReportRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

public protocol ReportRepositoryProtocol {

    /// 제보를 등록합니다.
    /// - Parameters:
    ///   - title: 제보 제목
    ///   - content: 제보 내용
    ///   - category: 제보 카테고리
    ///   - location: 제보 위치
    ///   - photos: 업로드한 사진의 presigned urls
    /// - Returns: 제보 id
    func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photoURLs: [String]
    ) async throws -> Int?

    /// 제보 목록을 조회합니다.
    /// - Returns: 조회된 제보 목록
    func fetchReports() async throws -> [ReportEntity]

    /// 제보 상세 기록을 조회합니다.
    /// - Parameter reportId: 조회할 제보의 ID
    /// - Returns: 조회된 제보
    func fetchReportDetail(reportId: Int) async throws -> ReportEntity?
}
