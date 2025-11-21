//
//  ReportHistoryViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Combine
import Domain
import Foundation

final class ReportHistoryViewModel: ViewModel {
    enum Input {
        case fetchReports
        case filterCategory(type: ReportType)
        case filterProgress(progress: ReportProgress) 
    }

    struct Output {
        let progressPublisher: AnyPublisher<[ReportProgressItem], Never>
        let selectedProgressPublisher: AnyPublisher<ReportProgress?, Never>
        let categoryPublisher: AnyPublisher<[ReportType], Never>
        let selectedCategoryPublisher: AnyPublisher<ReportType?, Never>
        let reportsPublisher: AnyPublisher<[ReportHistoryItem], Never>
        let selectedReportPublisher: AnyPublisher<Int?, Never>
    }

    private(set) var output: Output
    private let progressSubject = CurrentValueSubject<[ReportProgressItem], Never>([])
    private let selectedProgressSubject = CurrentValueSubject<ReportProgress?, Never>(nil)
    private let categorySubject = CurrentValueSubject<[ReportType], Never>([])
    private let selectedCategorySubject = CurrentValueSubject<ReportType?, Never>(nil)
    private let reportSubject = CurrentValueSubject<[ReportHistoryItem], Never>([])
    private let selectedReportSubject = PassthroughSubject<Int?, Never>()
    private(set) var selectedReportCategory: ReportType?
    private var reports: [ReportHistoryItem] = []
    private let reportRepository: ReportRepositoryProtocol

    init(reportRepository: ReportRepositoryProtocol) {
        self.reportRepository = reportRepository
        progressSubject
            .send(
                ReportProgress.allCases.map { ReportProgressItem(
                    uuid: UUID(),
                    progress: $0,
                    count: 0,
                    isSelected: $0 == .entire)})
        categorySubject.send(ReportType.allCases)

        output = Output(
            progressPublisher: progressSubject.eraseToAnyPublisher(),
            selectedProgressPublisher: selectedProgressSubject.eraseToAnyPublisher(),
            categoryPublisher: categorySubject.eraseToAnyPublisher(),
            selectedCategoryPublisher: selectedCategorySubject.eraseToAnyPublisher(),
            reportsPublisher: reportSubject.eraseToAnyPublisher(),
            selectedReportPublisher: selectedReportSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchReports:
            fetchReports()
        case .filterCategory(let type):
            filterCategory(reportType: type)
        case .filterProgress(let progress):
            filterProgress(progress: progress)
        }
    }

    private func filterCategory(reportType: ReportType) {
        let currentType: ReportType?

        if
            let previousType = selectedCategorySubject.value,
            previousType == reportType
        {
            currentType = nil
        } else {
            currentType = reportType
        }

        selectedReportCategory = currentType
        selectedCategorySubject.send(currentType)
        filterReports()
    }

    private func filterProgress(progress: ReportProgress) {
        var progressItems = progressSubject.value

        for i in 0..<progressItems.count {
            if progressItems[i].progress == progress {
                progressItems[i].isSelected.toggle()
            } else {
                progressItems[i].isSelected = false
            }
        }

        progressSubject.send(progressItems)

        filterReports()
    }

    private func filterReports() {
        let selectedProgress = selectedProgressSubject.value
        let selectedCategory = selectedCategorySubject.value

        var filteredReports = reports
        if let selectedProgress {
            filteredReports = filteredReports.filter({ $0.progress == selectedProgress })
        }
        if let selectedCategory {
            filteredReports = filteredReports.filter({ $0.type == selectedCategory })
        }
        reportSubject.send(filteredReports)
    }

    private func fetchReports() {
        Task {
            do {
                let reportEntities = try await reportRepository.fetchReports()

                var reportHistoryItems: [ReportHistoryItem] = []
                for reportEntity in reportEntities {
                    let reportHistoryItem = ReportHistoryItem(
                        id: reportEntity.id,
                        title: reportEntity.title,
                        thumbnailUrl: reportEntity.photoUrls.first ?? "",
                        date: reportEntity.date ?? "",
                        type: reportEntity.type,
                        progress: reportEntity.progress,
                        location: reportEntity.location.address ?? "")
                    reportHistoryItems.append(reportHistoryItem)
                }

                reports = reportHistoryItems
                reportSubject.send(reportHistoryItems)
            } catch {
                // TODO: 에러 처리
            }
        }
    }
}
