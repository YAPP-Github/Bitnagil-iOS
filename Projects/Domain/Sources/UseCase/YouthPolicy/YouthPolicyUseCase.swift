//
//  YouthPolicyUseCase.swift
//  Domain
//

public final class YouthPolicyUseCase: YouthPolicyUseCaseProtocol {
    private let youthPolicyRepository: YouthPolicyRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol

    public init(
        youthPolicyRepository: YouthPolicyRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol
    ) {
        self.youthPolicyRepository = youthPolicyRepository
        self.locationRepository = locationRepository
    }

    public func fetchPolicies(cursor: String?, size: Int?) async throws -> YouthPolicyPageEntity? {
        guard
            let coordinate = await locationRepository.fetchCoordinate(),
            let latitude = coordinate.latitude,
            let longitude = coordinate.longitude
        else { return nil }

        return try await youthPolicyRepository.fetchPolicies(
            latitude: latitude,
            longitude: longitude,
            cursor: cursor,
            size: size)
    }

    public func fetchBookmarkedPolicies(cursor: String?, size: Int?) async throws -> YouthPolicyPageEntity {
        return try await youthPolicyRepository.fetchBookmarkedPolicies(cursor: cursor, size: size)
    }

    public func updateBookmark(policyNumber: String, isBookmarked: Bool) async throws {
        if isBookmarked {
            try await youthPolicyRepository.addBookmark(policyNumber: policyNumber)
        } else {
            try await youthPolicyRepository.removeBookmark(policyNumber: policyNumber)
        }
    }
}
