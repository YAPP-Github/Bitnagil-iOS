//
//  ActivityHistoryViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/1/26.
//

import Combine
import Foundation

final class ActivityHistoryViewModel: ViewModel {
    enum Input {
        case fetchMonthlyBadge(date: Date)
        case fetchMonthlyEmotionHistory(date: Date)
    }
    
    struct Output {
        let monthlyBadgePublisher: AnyPublisher<[ActivityBadge], Never>
        let monthlyEmotionHistoryPublisher: AnyPublisher<[String: Marble], Never>
    }
    
    private(set) var output: Output
    private let monthlyBadgeSubject = CurrentValueSubject<[ActivityBadge], Never>([])
    private let monthlyEmotionHistorySubject = CurrentValueSubject<[String: Marble], Never>([:])
    
    init() {
        self.output = Output(
            monthlyBadgePublisher: monthlyBadgeSubject.eraseToAnyPublisher(),
            monthlyEmotionHistoryPublisher: monthlyEmotionHistorySubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchMonthlyBadge(let date):
            // TODO: 추후 서버 로직 붙이기
            Task {
                let badges: [ActivityBadge] = []
                monthlyBadgeSubject.send(badges)
            }
        case .fetchMonthlyEmotionHistory(let date):
            // TODO: 추후 서버 로직 붙이기
            Task {
                let mockEmotionRecords: [String: Marble] = [
                    "2026-07-01": .ANXIETY,
                    "2026-07-05": .FATIGUE,
                    "2026-07-11": .LETHARGY,
                    "2026-07-16": .VITALITY,
                    "2026-07-23": .CALM
                ]
                monthlyEmotionHistorySubject.send(mockEmotionRecords)
            }
        }
    }
}
