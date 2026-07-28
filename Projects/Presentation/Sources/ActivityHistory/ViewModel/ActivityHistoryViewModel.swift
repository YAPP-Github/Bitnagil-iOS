//
//  ActivityHistoryViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/1/26.
//

import Combine
import Domain
import Foundation
import Shared

final class ActivityHistoryViewModel: ViewModel {
    enum Input {
        case invalidateCacheAndRefetch
        case fetchMonthlyBadge(date: Date)
        case fetchEmotionHistory(date: Date)
    }
    
    struct Output {
        let monthlyBadgePublisher: AnyPublisher<ActivityBadge, Never>
        let monthlyEmotionHistoryPublisher: AnyPublisher<[String: EmotionMarble], Never>
    }

    private(set) var output: Output
    private let calendar = Calendar.current
    private var emotionHistoryCache: [String: [String: EmotionMarble]] = [:]

    private let monthlyBadgeSubject = PassthroughSubject<ActivityBadge, Never>()
    private let monthlyEmotionHistorySubject = CurrentValueSubject<[String: EmotionMarble], Never>([:])

    private let activityHistoryRepository: ActivityHistoryRepositoryProtocol
    private let networkRetryHandler: NetworkRetryHandler

    init(activityHistoryRepository: ActivityHistoryRepositoryProtocol) {
        self.activityHistoryRepository = activityHistoryRepository
        self.networkRetryHandler = NetworkRetryHandler()

        self.output = Output(
            monthlyBadgePublisher: monthlyBadgeSubject.eraseToAnyPublisher(),
            monthlyEmotionHistoryPublisher: monthlyEmotionHistorySubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .invalidateCacheAndRefetch:
            emotionHistoryCache.removeAll()
            fetchMonthlyBadge(date: .now)
            fetchEmotionHistory(date: .now)

        case .fetchMonthlyBadge(let date):
            fetchMonthlyBadge(date: date)

        case .fetchEmotionHistory(let date):
            fetchEmotionHistory(date: date)
        }
    }

    private func fetchMonthlyBadge(date: Date) {
        Task {
            do {
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let badgeEntity = try await activityHistoryRepository.fetchMonthlyBadges(year: year, month: month)
                monthlyBadgeSubject.send(badgeEntity.toActivityBadge())
            } catch {
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    private func fetchEmotionHistory(date: Date) {
        let key = monthKey(for: date)

        if let cachedEmotionHistory = emotionHistoryCache[key] {
            monthlyEmotionHistorySubject.send(cachedEmotionHistory)
            return
        }

        Task {
            do {
                guard
                    let firstDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
                    let lastDate = calendar.date(byAdding: DateComponents(month: 1, day: -1),to: firstDate),
                    let startDate = calendar.date(byAdding: .day, value: -6, to: firstDate),
                    let endDate = calendar.date(byAdding: .day, value: 6, to: lastDate)
                else { return }

                let startDateString = startDate.convertToString(dateType: .yearMonthDate)
                let endDateString = endDate.convertToString(dateType: .yearMonthDate)
                let emotionHistoryEntities = try await activityHistoryRepository.fetchEmotionMarbles(startDate: startDateString, endDate: endDateString)

                var emotionHistoryRecords: [String: EmotionMarble] = [:]
                for emotionHistory in emotionHistoryEntities {
                    guard let marble = Marble(rawValue: emotionHistory.emotionMarbleType)
                    else { return }

                    let emotionMarble = EmotionMarble(marble: marble, imageUrl: emotionHistory.imageUrl)
                    emotionHistoryRecords[emotionHistory.date] = emotionMarble
                }

                emotionHistoryCache[key] = emotionHistoryRecords
                monthlyEmotionHistorySubject.send(emotionHistoryRecords)
            } catch {
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    private func monthKey(for date: Date) -> String {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        return String(format: "%04d-%02d", year, month)
    }
}
