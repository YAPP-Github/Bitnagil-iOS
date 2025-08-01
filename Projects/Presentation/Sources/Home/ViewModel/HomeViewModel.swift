//
//  HomeViewModel.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Combine
import Domain
import Foundation

final class HomeViewModel: ViewModel {
    enum Input {
        case loadNickname
        case fetchRoutines
        case fetchDailyRoutines(date: Date)
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let fetchRoutineResultPublisher: AnyPublisher<Bool, Never>
        let routinesPublisher: AnyPublisher<[MainRoutine], Never>
    }

    private(set) var output: Output
    private var routines: [String: [MainRoutine]] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let fetchRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let routinesSubject = CurrentValueSubject<[MainRoutine], Never>([])

    private let calendar = Calendar.current
    private var oldestDate: Date = Date()
    private var latestDate: Date = Date()
    private let routineUseCase: RoutineUseCaseProtocol
    private let userDataUseCase: UserDataUseCaseProtocol
    init(routineUseCase: RoutineUseCaseProtocol, userDataUseCase: UserDataUseCaseProtocol) {
        self.routineUseCase = routineUseCase
        self.userDataUseCase = userDataUseCase
        self.output = Output(
            nicknamePublisher: nicknameSubject.eraseToAnyPublisher(),
            fetchRoutineResultPublisher: fetchRoutineResultSubject.eraseToAnyPublisher(),
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
        Task {
            do {
                let nickname = try await userDataUseCase.loadNickname()
                nicknameSubject.send(nickname)
            } catch {
                
            }
        }
    }

    private func fetchRoutines() {
        var startDate = oldestDate
        var endDate = latestDate

        if routines.isEmpty {
            let today = Date()
            startDate = calculateDate(for: today, offset: -1)
            endDate = calculateDate(for: today, offset: 1)

            oldestDate = startDate
            latestDate = endDate
        }

        Task {
            do {
                let entities = try await routineUseCase.fetchRoutines(startDate: startDate, endDate: endDate)
                for (date, routineEntities) in entities {
                    routines[date] = routineEntities.map({ $0.toMainRoutine() })
                }
                fetchRoutineResultSubject.send(true)
            } catch {

            }
        }
    }

    private func fetchRoutines(for date: Date) {
        if date <= oldestDate {
            oldestDate = calendar.date(byAdding: .weekOfYear, value: -1, to: date) ?? date
            latestDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        } else if date >= latestDate {
            oldestDate = calendar.date(byAdding: .day, value: 1, to: date) ?? date
            latestDate = calendar.date(byAdding: .weekOfYear, value: 1, to: date) ?? date
        }

        let dateKey = date.convertToString(dateType: .yearMonthDate)
        guard let dailyRoutines = routines[dateKey] else {
            fetchRoutines()
            return
        }
        routinesSubject.send(dailyRoutines)
    }

    // 필요 시, 루틴 데이터를 불러옵니다. (+- 주)
    private func calculateDate(for date: Date, offset week: Int) -> Date {
        let endDate = calendar.date(byAdding: .weekOfYear, value: week, to: date) ?? date
        return endDate
    }
}
