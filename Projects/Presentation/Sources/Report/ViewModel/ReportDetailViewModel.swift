//
//  ReportDetailViewModel.swift
//  Presentation
//
//  Created by 최정인 on 11/18/25.
//

import Combine
import Domain

final class ReportDetailViewModel: ViewModel {
    enum Input {
        case fetchReportDetail(reportId: Int)
    }

    struct Output {
        let reportDetailPublisher: AnyPublisher<ReportDetail?, Never>
    }

    private(set) var output: Output
    private let reportDetailSubject = CurrentValueSubject<ReportDetail?, Never>(nil)
    private let reportRepository: ReportRepositoryProtocol

    init(reportRepository: ReportRepositoryProtocol) {
        self.reportRepository = reportRepository
        self.output = Output(
            reportDetailPublisher: reportDetailSubject.eraseToAnyPublisher()
        )
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
                    let reportDetail = ReportDetail(
                        date: reportEntity.date ?? "",
                        title: reportEntity.title,
                        status: reportEntity.progress,
                        category: reportEntity.type,
                        description: reportEntity.content ?? "",
                        location: reportEntity.location.address ?? "",
                        photoUrls: reportEntity.photoUrls)
                    reportDetailSubject.send(reportDetail)
                }
                reportDetailSubject.send(nil)
            } catch {
                reportDetailSubject.send(nil)
            }
        }
    }
}
