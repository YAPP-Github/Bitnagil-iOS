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
        case fetchReportDetail
    }

    struct Output {
        let reportDetailPublisher: AnyPublisher<ReportDetail?, Never>
    }

    private(set) var output: Output
    private let reportDetailSubject = CurrentValueSubject<ReportDetail?, Never>(nil)

    init() {
        self.output = Output(
            reportDetailPublisher: reportDetailSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .fetchReportDetail:
            fetchReportDetail()
        }
    }

    private func fetchReportDetail() {
        let report = ReportDetail(
            date: "2025.11.03 (금)",
            title: "가로등이 깜빡거려요.",
            category: .water,
            description: "가로등이 깜박거리고 치지직 거려서 곧 터질 것 같아요... 햇살이 유리창 너머로 스며들며 방 안을 부드럽게 채운다. 커피 향이 퍼지고, 어제의 고민이 조금은 멀게 느껴진다. 오늘은 완벽하지 않아도 괜찮다. 천천히 숨을 고르고, 다시 한 걸음 내딛으면 된다. 이게 뭐람.",
            location: "서울특별시 강남구 삼성동")

        reportDetailSubject.send(report)
    }
}
