//
//  YouthPolicyEntity.swift
//  Domain
//

import Foundation

public struct YouthPolicyEntity {
    /// 공고 고유 번호. 찜 등록/해제 시 이 값을 사용합니다.
    public let policyNumber: String
    public let title: String
    /// 대분류(일자리·주거·교육 등). 일부 공고에서 nil.
    public let category: String?
    /// 원본 API에 이미지가 없어 현재는 항상 nil입니다. 클라이언트 기본 이미지를 사용하세요.
    public let thumbnailURL: String?
    public let status: YouthPolicyStatus
    /// 신청 시작일. 상시/마감 공고에서 nil 가능.
    public let startDate: Date?
    /// 신청 마감일. 상시 공고는 nil.
    public let endDate: Date?
    /// 마감까지 남은 일수(오늘 = 0). status가 open이 아니면 nil.
    public let dday: Int?
    /// 외부 신청 페이지 URL. 없을 수 있습니다.
    public let applyURL: String?
    public let isBookmarked: Bool

    public init(
        policyNumber: String,
        title: String,
        category: String?,
        thumbnailURL: String?,
        status: YouthPolicyStatus,
        startDate: Date?,
        endDate: Date?,
        dday: Int?,
        applyURL: String?,
        isBookmarked: Bool
    ) {
        self.policyNumber = policyNumber
        self.title = title
        self.category = category
        self.thumbnailURL = thumbnailURL
        self.status = status
        self.startDate = startDate
        self.endDate = endDate
        self.dday = dday
        self.applyURL = applyURL
        self.isBookmarked = isBookmarked
    }
}
