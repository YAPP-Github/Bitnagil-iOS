//
//  YouthPolicyRepositoryProtocol.swift
//  Domain
//

public protocol YouthPolicyRepositoryProtocol {

    /// 현위치 기준 청년 공고 목록을 조회합니다. 마감된 공고는 제외됩니다.
    /// - Parameters:
    ///   - latitude: 현재 위도
    ///   - longitude: 현재 경도
    ///   - cursor: 이전 응답의 nextCursor. 첫 페이지는 nil
    ///   - size: 페이지 크기. nil이면 서버 기본값(10) 사용
    /// - Returns: 공고 페이지
    func fetchPolicies(
        latitude: Double,
        longitude: Double,
        cursor: String?,
        size: Int?
    ) async throws -> YouthPolicyPageEntity

    /// 찜한 공고 목록을 조회합니다. 지역과 무관하며 마감된 공고도 포함됩니다.
    /// - Parameters:
    ///   - cursor: 이전 응답의 nextCursor. 첫 페이지는 nil
    ///   - size: 페이지 크기. nil이면 서버 기본값(10) 사용
    /// - Returns: 공고 페이지
    func fetchBookmarkedPolicies(
        cursor: String?,
        size: Int?
    ) async throws -> YouthPolicyPageEntity

    /// 공고를 찜 목록에 추가합니다. 멱등이므로 이미 찜한 공고를 다시 호출해도 성공합니다.
    /// - Parameter policyNumber: 공고 번호
    func addBookmark(policyNumber: String) async throws

    /// 공고를 찜 목록에서 제거합니다. 멱등이므로 찜하지 않은 공고를 해제해도 성공합니다.
    /// - Parameter policyNumber: 공고 번호
    func removeBookmark(policyNumber: String) async throws
}
