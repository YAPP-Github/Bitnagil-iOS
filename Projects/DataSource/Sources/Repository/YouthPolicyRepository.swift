//
//  YouthPolicyRepository.swift
//  DataSource
//

import Domain
import Foundation

final class YouthPolicyRepository: YouthPolicyRepositoryProtocol {
    private let networkService = NetworkService.shared

    func fetchPolicies(
        latitude: Double,
        longitude: Double,
        cursor: String?,
        size: Int?
    ) async throws -> YouthPolicyPageEntity {
        let endpoint = YouthPolicyEndpoint.fetchPolicies(
            latitude: latitude,
            longitude: longitude,
            cursor: cursor,
            size: size)

        return try await fetchPage(endpoint: endpoint)
    }

    func fetchBookmarkedPolicies(
        cursor: String?,
        size: Int?
    ) async throws -> YouthPolicyPageEntity {
        let endpoint = YouthPolicyEndpoint.fetchBookmarkedPolicies(cursor: cursor, size: size)

        return try await fetchPage(endpoint: endpoint)
    }

    func addBookmark(policyNumber: String) async throws {
        let endpoint = YouthPolicyEndpoint.addBookmark(policyNumber: policyNumber)

        try await updateBookmark(endpoint: endpoint)
    }

    func removeBookmark(policyNumber: String) async throws {
        let endpoint = YouthPolicyEndpoint.removeBookmark(policyNumber: policyNumber)

        try await updateBookmark(endpoint: endpoint)
    }

    private func fetchPage(endpoint: YouthPolicyEndpoint) async throws -> YouthPolicyPageEntity {
        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: YouthPolicyPageDTO.self)
            else { return YouthPolicyPageEntity(policies: [], totalCount: 0, hasNext: false, nextCursor: nil) }

            return response.toYouthPolicyPageEntity()
        } catch let error as NetworkError {
            throw error.toDomainError()
        } catch {
            throw DomainError.unknown
        }
    }

    private func updateBookmark(endpoint: YouthPolicyEndpoint) async throws {
        do {
            _ = try await networkService.request(endpoint: endpoint, type: EmptyResponseDTO.self)
        } catch let error as NetworkError {
            throw error.toDomainError()
        } catch {
            throw DomainError.unknown
        }
    }
}

private extension NetworkError {
    func toDomainError() -> DomainError {
        switch self {
        case .needRetry, .invalidURL, .emptyData:
            return DomainError.requireRetry
        default:
            return DomainError.business(description)
        }
    }
}
