//
//  MetaAnalyticsLogger.swift
//  App
//
//  Created by 이동현 on 8/22/25.
//

import Domain
import FacebookCore
import Foundation

/// 도메인 이벤트를 Meta(Facebook) 광고 전환 이벤트로 변환해 전송합니다.
/// "첫 루틴 완료만 전송" 같은 트래킹 정책(중복 제거 포함)은 이 어댑터가 책임집니다.
final class MetaAnalyticsLogger: AnalyticsLoggerProtocol {

    private enum StorageKey {
        static let didLogFirstRoutineCompletion = "didLogFirstRoutineCompletion"
    }

    func log(_ event: AnalyticsEvent) {
        switch event {
        case .signUpCompleted:
            AppEvents.shared.logEvent(.completedRegistration)

        case .onboardingCompleted:
            AppEvents.shared.logEvent(.completedTutorial)

        case .routineCompleted:
            // 광고 최적화 신호 왜곡을 막기 위해 첫 루틴 완료만 전환 이벤트로 전송합니다.
            guard !UserDefaults.standard.bool(forKey: StorageKey.didLogFirstRoutineCompletion) else { return }
            UserDefaults.standard.set(true, forKey: StorageKey.didLogFirstRoutineCompletion)
            AppEvents.shared.logEvent(.achievedLevel)
        }
    }
}
