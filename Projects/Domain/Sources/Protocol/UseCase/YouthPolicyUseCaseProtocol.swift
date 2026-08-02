//
//  YouthPolicyUseCaseProtocol.swift
//  Domain
//

public protocol YouthPolicyUseCaseProtocol {

    /// 현위치를 조회한 뒤 해당 지역의 청년 공고 목록을 가져옵니다.
    /// - Parameters:
    ///   - cursor: 이전 응답의 nextCursor. 첫 페이지는 nil
    ///   - size: 페이지 크기. nil이면 서버 기본값 사용
    /// - Returns: 공고 페이지. 위치 권한이 없거나 좌표를 얻지 못하면 nil
    func fetchPolicies(cursor: String?, size: Int?) async throws -> YouthPolicyPageEntity?

    /// 찜한 공고 목록을 가져옵니다.
    /// - Parameters:
    ///   - cursor: 이전 응답의 nextCursor. 첫 페이지는 nil
    ///   - size: 페이지 크기. nil이면 서버 기본값 사용
    /// - Returns: 공고 페이지
    func fetchBookmarkedPolicies(cursor: String?, size: Int?) async throws -> YouthPolicyPageEntity

    /// 공고의 찜 상태를 변경합니다.
    /// - Parameters:
    ///   - policyNumber: 공고 번호
    ///   - isBookmarked: 변경할 찜 상태. true면 등록, false면 해제
    func updateBookmark(policyNumber: String, isBookmarked: Bool) async throws
}
