//
//  HomeViewModel.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Combine
import Foundation

final class HomeViewModel: ViewModel {
    enum Input {
        case loadNickname
        case fetchRoutines
        case fetchDailyRoutines(date: Date)
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let routinesPublisher: AnyPublisher<[MainRoutine], Never>
    }

    private(set) var output: Output
    private var routines: [String: [MainRoutine]] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let routinesSubject = CurrentValueSubject<[MainRoutine], Never>([])

    init() {
        self.output = Output(
            nicknamePublisher: nicknameSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .loadNickname:
            loadNickname()

        case .fetchRoutines:
            fetchRoutines()

        case .fetchDailyRoutines(let date):
            fetchRoutines(for: date)
        }
    }

    private func loadNickname() {
        // TODO: Repository 혹은 UseCase와 연동해야 합니다.
        nicknameSubject.send("선영")
    }

    private func fetchRoutines() {
        // TODO: 서버 통신 로직으로 교체해야 합니다.
        let mainRoutine1 = MainRoutine(
            id: 1,
            startTime: .now,
            title: "개운하게 일어나기",
            isDone: false,
            subRoutines: [
                SubRoutine(id: 1, title: "물 마시기", isDone: true),
                SubRoutine(id: 2, title: "물 마시기", isDone: false),
                SubRoutine(id: 3, title: "물 마시기", isDone: false)
            ])

        let mainRoutine2 = MainRoutine(
            id: 2,
            startTime: .now,
            title: "떵인이 응원하기",
            isDone: false,
            subRoutines: [])

        let mainRoutine3 = MainRoutine(
            id: 3,
            startTime: .now,
            title: "아자아자 힘내기",
            isDone: false,
            subRoutines: [
                SubRoutine(id: 1, title: "힘을내라고말해줄래", isDone: false),
                SubRoutine(id: 2, title: "두 눈을 반짝여", isDone: false),
                SubRoutine(id: 2, title: "날 일으켜줄래", isDone: false),
            ])

        let mainRoutine4 = MainRoutine(
            id: 4,
            startTime: .now,
            title: "반짝반짝",
            isDone: false,
            subRoutines: [
                SubRoutine(id: 1, title: "눈이 부셔", isDone: false),
                SubRoutine(id: 2, title: "노노노노노노", isDone: false)
            ])

        routines["2025-07-24"] = [mainRoutine1, mainRoutine2, mainRoutine4]
        routines["2025-08-02"] = [mainRoutine3]
    }

    private func fetchRoutines(for date: Date) {
        let dateKey = date.convertToString(dateType: .yearMonthDate)
        guard let dailyRoutines = routines[dateKey] else {
            routinesSubject.send([])
            return
        }
        routinesSubject.send(dailyRoutines)
    }
}
