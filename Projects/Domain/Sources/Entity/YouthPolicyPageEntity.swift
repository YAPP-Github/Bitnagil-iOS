//
//  YouthPolicyPageEntity.swift
//  Domain
//

public struct YouthPolicyPageEntity {
    public let policies: [YouthPolicyEntity]
    /// 필터링된 전체 건수. 탭의 "전체 N" 표기용이며 페이지마다 동일하게 내려옵니다.
    public let totalCount: Int
    public let hasNext: Bool
    /// 다음 페이지 요청에 그대로 넘길 불투명 토큰. hasNext가 false면 nil.
    public let nextCursor: String?

    public init(
        policies: [YouthPolicyEntity],
        totalCount: Int,
        hasNext: Bool,
        nextCursor: String?
    ) {
        self.policies = policies
        self.totalCount = totalCount
        self.hasNext = hasNext
        self.nextCursor = nextCursor
    }
}
