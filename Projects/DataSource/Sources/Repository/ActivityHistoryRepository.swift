//
//  ActivityHistoryRepository.swift
//  DataSource
//
//  Created by 최정인 on 7/21/26.
//

import Domain

final class ActivityHistoryRepository: ActivityHistoryRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchMonthlyBadges(year: Int, month: Int) async throws -> BadgeEntity {
        let endpoint = ActivityHistoryEndpoint.fetchMonthlyBadges(year: "\(year)", month: "\(month)")
        do {
            guard let monthlyBadgesDTO = try await networkService.request(endpoint: endpoint, type: MonthlyBadgesDTO.self)
            else { throw NetworkError.decodingError }
            return monthlyBadgesDTO.toBadgeEntity()
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }

    func fetchEmotionMarbles(startDate: String, endDate: String) async throws -> [EmotionHistoryEntity] {
        let endpoint = ActivityHistoryEndpoint.fetchEmotionHistory(startDate: startDate, endDate: endDate)

        do {
            guard let emotionMarbleDTOs = try await networkService.request(endpoint: endpoint, type: [EmotionMarbleHistoryDTO].self)
            else { throw NetworkError.decodingError }
            return emotionMarbleDTOs.map { $0.toEmotionHistoryEntity() }
        } catch let error as NetworkError {
            switch error {
            case .needRetry, .invalidURL, .emptyData:
                throw DomainError.requireRetry
            default:
                throw DomainError.business(error.description)
            }
        } catch {
            throw DomainError.unknown
        }
    }
}
