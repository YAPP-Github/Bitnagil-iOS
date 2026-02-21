//
//  ReportRepository.swift
//  DataSource
//
//  Created by 이동현 on 11/9/25.
//

import Domain
import Foundation

final class ReportRepository: ReportRepositoryProtocol {
    private let networkService = NetworkService.shared

    func report(
        title: String,
        content: String?,
        category: ReportType,
        location: LocationEntity?,
        photoURLs: [String]
    ) async throws -> Int? {
        let reportDTO = ReportDTO(
            reportId: nil,
            reportDate: nil,
            reportTitle: title,
            reportContent: content,
            reportLocation: location?.address ?? "",
            reportStatus: nil,
            reportCategory: category.description,
            reportImageUrl: nil,
            reportImageUrls: photoURLs,
            latitude: location?.latitude,
            longitude: location?.longitude
        )

        let endpoint = ReportEndpoint.register(report: reportDTO)

        do {
            guard let id = try await networkService.request(endpoint: endpoint, type: Int.self) else { return nil }

            return id
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

    func fetchReports() async throws -> [ReportEntity] {
        let endpoint = ReportEndpoint.fetchReports

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: ReportDictonaryDTO.self)
            else { return [] }

            var reportEntities: [ReportEntity] = []
            for (date, reports) in response.reportInfos {
                let reportHistories = reports.compactMap({ try? $0.toReportEntity(date: date) })
                reportEntities += reportHistories
            }

            return reportEntities
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

    func fetchReportDetail(reportId: Int) async throws -> ReportEntity? {
        let endpoint = ReportEndpoint.fetchReportDetail(reportId: reportId)

        do {
            guard let response = try await networkService.request(endpoint: endpoint, type: ReportDTO.self)
            else { return nil }

            return try response.toReportEntity()
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
