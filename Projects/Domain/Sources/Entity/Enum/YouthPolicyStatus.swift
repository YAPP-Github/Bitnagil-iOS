//
//  YouthPolicyStatus.swift
//  Domain
//

public enum YouthPolicyStatus: String {
    /// 신청 기간 내 (마감 전)
    case open = "OPEN"
    /// 상시 모집
    case always = "ALWAYS"
    /// 마감됨. 찜 목록에서만 내려옵니다.
    case closed = "CLOSED"
}
