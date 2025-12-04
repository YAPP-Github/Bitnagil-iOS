//
//  ReportUseCase.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

public final class ReportUseCase: ReportUseCaseProtocol {
    private let locationRepository: LocationRepositoryProtocol
    private let fileRepository: FileRepositoryProtocol
    private let reportRepository: ReportRepositoryProtocol

    public init(
        locationRepository: LocationRepositoryProtocol,
        reportRepository: ReportRepositoryProtocol,
        fileRepository: FileRepositoryProtocol
    ) {
        self.locationRepository = locationRepository
        self.reportRepository = reportRepository
        self.fileRepository = fileRepository
    }

    public func fetchCurrentLocation() async throws -> LocationEntity? {
        guard let coordinate = await locationRepository.fetchCoordinate() else { return nil }

        return try await locationRepository.fetchAddress(coordinate: coordinate)
    }

    public func fetchReports() async throws -> [ReportEntity] {
        return try await reportRepository.fetchReports()
    }

    public func fetchReport(reportId: Int) async throws -> ReportEntity? {
        return try await reportRepository.fetchReportDetail(reportId: reportId)
    }

    public func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photos: [Data]
    ) async throws -> Int? {
        if photos.isEmpty { return nil }

        let fileNames = (1...photos.count).map { "\($0).jpg" }

        // TODO: - 사진 업로드 실패 시 에러 처리 필요
        guard
            let presignedDict = try await fileRepository.fetchPresignedURL(prefix: "report", fileNames: fileNames),
            presignedDict.count == photos.count
        else { return nil }

        for (url, photo) in zip(presignedDict.values, photos) {
            do {
                try await fileRepository.uploadFile(url: url, data: photo)
            } catch {
                print(error.localizedDescription)
            }
        }

        let publicImageURLs = presignedDict.values.map { url in
            url.split(separator: "?", maxSplits: 1)
                .map(String.init)
                .first ?? url
        }

        return try await reportRepository.report(
            title: title,
            content: content,
            category: category,
            location: location,
            photoURLs: publicImageURLs)
    }
}
