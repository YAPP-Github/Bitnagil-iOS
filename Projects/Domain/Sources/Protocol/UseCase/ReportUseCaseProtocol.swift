//
//  ReportUseCaserProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

public protocol ReportUseCaseProtocol {
    /// 현위치를 가져옵니다.
    /// - Returns: 현재 위치
    func fetchCurrentLocation() async throws -> LocationEntity?

    /// 제보 목록을 가져옵니다.
    /// - Returns: 제보 목록
    func fetchReports() async throws -> [ReportEntity]

    /// 제보 단건의 상세 정보를 조회합니다.
    /// - Parameter reportId: 제보 id
    /// - Returns: 제보 상세 정보
    func fetchReport(reportId: Int) async throws -> ReportEntity?

    /// 제보를 등록합니다.
    /// - Parameters:
    ///   - title: 제보 제목
    ///   - content: 제보 내용
    ///   - category: 제보 카테고리 (교통, 상하수도 등)
    ///   - location: 제보 위치
    ///   - photos: 제보 사진 배열
    /// - Returns: 등록한 제보 id
    func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photos: [Data]
    ) async throws -> Int?
}
