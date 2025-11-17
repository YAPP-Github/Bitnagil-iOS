//
//  ReportUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public final class ReportUseCase: ReportUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol
    private let reportRepository: ReportRepositoryProtocol

    public init(locationRepository: LocationRepositoryProtocol, reportRepository: ReportRepositoryProtocol) {
        self.locationRepository = locationRepository
        self.reportRepository = reportRepository
    }

    public func fetchCurrentLocation() async throws -> LocationEntity? {
        guard let coordinate = await locationRepository.fetchCoordinate() else { return nil }

        return try await locationRepository.fetchAddress(coordinate: coordinate)
    }

    public func report(reportEntity: ReportEntity) async {

    }
}
