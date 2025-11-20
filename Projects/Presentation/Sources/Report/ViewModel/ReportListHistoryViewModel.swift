//
//  ReportHistoryViewModel.swift
//  Presentation
//
//  Created by 이동현 on 11/15/25.
//

import Combine
import Domain
import Foundation

final class ReportListHistoryViewModel: ViewModel {
    enum Input {
        case fetchReports
        case fetchReport(index: Int)
        case filterCategory(type: ReportType)
        case filterProgress(progress: ReportProgress) 
    }

    struct Output {
        let progressPublisher: AnyPublisher<[ReportProgressItem], Never>
        let categoryPublisher: AnyPublisher<[ReportType], Never>
        let selectedCategoryPublisher: AnyPublisher<ReportType?, Never>
        let reportsPublisher: AnyPublisher<[ReportHistoryItem], Never>
        let selectedReportPublisher: AnyPublisher<Int?, Never>
    }

    private(set) var output: Output
    private let progressSubject = CurrentValueSubject<[ReportProgressItem], Never>([])
    private let categorySubject = CurrentValueSubject<[ReportType], Never>([])
    private let selectedCategorySubject = CurrentValueSubject<ReportType?, Never>(nil)
    private let reportSubject = CurrentValueSubject<[ReportHistoryItem], Never>([])
    private let selectedReportSubject = PassthroughSubject<Int?, Never>()
    private var reports: [ReportHistoryItem] = []

    init() {
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
            categoryPublisher: categorySubject.eraseToAnyPublisher(),
            selectedCategoryPublisher: selectedCategorySubject.eraseToAnyPublisher(),
            reportsPublisher: reportSubject.eraseToAnyPublisher(),
            selectedReportPublisher: selectedReportSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchReports:
            fetchReports()
        case .fetchReport(let index):
            fetchReport(index: index)
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

    }

    private func fetchReports() {
        reportSubject.send(ReportHistoryItem.dummyData)
    }

    private func fetchReport(index: Int) {
        guard index < reports.count else { return }

        selectedReportSubject.send(reports[index].id)
    }
}
