//
//  AnalyticsEvent.swift
//  Domain
//
//  Created by 이동현 on 8/22/25.
//

/// 광고 전환 측정 등 분석 도구로 전달되는 도메인 이벤트입니다.
/// 도메인은 "어떤 일이 일어났는지"만 알리고, 전송 여부/횟수 등의 트래킹 정책은 구현체가 결정합니다.
public enum AnalyticsEvent {
    /// 회원가입(약관 동의) 완료
    case signUpCompleted
    /// 온보딩 완료
    case onboardingCompleted
    /// 루틴 완료
    case routineCompleted
}
