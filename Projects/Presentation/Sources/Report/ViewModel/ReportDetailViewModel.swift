//
//  ReportDetailViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/18/25.
//

import Combine
import Domain
import Foundation

final class ReportDetailViewModel: ViewModel {
    enum Input {
        case fetchReportDetail(reportId: Int)
    }

    struct Output {
        let reportDetailPublisher: AnyPublisher<ReportDetail?, Never>
        let networkErrorPublisher: AnyPublisher<(() -> Void)?, Never>
    }

    private(set) var output: Output
    private let reportDetailSubject = CurrentValueSubject<ReportDetail?, Never>(nil)
    private let reportRepository: ReportRepositoryProtocol
    private let networkRetryHandler: NetworkRetryHandler

    init(reportRepository: ReportRepositoryProtocol) {
        networkRetryHandler = NetworkRetryHandler()
        
        self.reportRepository = reportRepository
        self.output = Output(
            reportDetailPublisher: reportDetailSubject.eraseToAnyPublisher(),
            networkErrorPublisher: networkRetryHandler.networkErrorActionSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchReportDetail(let reportId):
            fetchReportDetail(reportId: reportId)
        }
    }

    private func fetchReportDetail(reportId: Int) {
        Task {
            do {
                if let reportEntity = try await reportRepository.fetchReportDetail(reportId: reportId) {
                    let date = Date.convertToDate(from: reportEntity.date ?? "", dateType: .yearMonthDate)
                    let dateString = date?.convertToString(dateType: .yearMonthDateWeek2)

                    let reportDetail = ReportDetail(
                        date: dateString ?? "",
                        title: reportEntity.title,
                        status: reportEntity.progress,
                        category: reportEntity.type,
                        description: reportEntity.content ?? "",
                        location: reportEntity.location.address ?? "",
                        photoUrls: reportEntity.photoURLs)
                    reportDetailSubject.send(reportDetail)
                }

                networkRetryHandler.clearRetryState()
            } catch {
                reportDetailSubject.send(nil)

                networkRetryHandler.handleNetworkError(error) { [weak self] in
                    self?.fetchReportDetail(reportId: reportId)
                }
            }
        }
    }
}
