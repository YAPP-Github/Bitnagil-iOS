//
//  RoutineListViewModel.swift
//  Presentation
//
//  Created by 최정인 on 8/18/25.
//

import Combine
import Domain
import Foundation

final class RoutineListViewModel: ViewModel {
    enum Input {
        case fetchRoutineList
        case selectDate(date: Date)
    }

    struct Output {
        let selectedDatePublisher: AnyPublisher<Date, Never>
        let routinesPublisher: AnyPublisher<[newRoutine], Never>
    }

    private(set) var output: Output
    private let selectedDateSubject = CurrentValueSubject<Date, Never>(Date())
    private let routinesSubject = CurrentValueSubject<[newRoutine], Never>([])
    private var routines: [String: [newRoutine]] = [:]

    private let calendar = Calendar.current
    private let routineRepository: RoutineRepositoryProtocol
    init(routineRepository: RoutineRepositoryProtocol) {
        self.routineRepository = routineRepository
        self.output = Output(
            selectedDatePublisher: selectedDateSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchRoutineList:
           fetchRoutines()

        case .selectDate(let date):
            selectedDateSubject.send(date)
            fetchDailyRoutine()
        }
    }

    private func fetchRoutines() {
        Task {
            do {
                let startDate = calculateWeekStartDate(for: selectedDateSubject.value)
                let endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? Date()
                let startDateString = startDate.convertToString(dateType: .yearMonthDate)
                let endDateString = endDate.convertToString(dateType: .yearMonthDate)

                let routinesDictionary = try await routineRepository.fetchRoutines2(from: startDateString, to: endDateString)
                for dailyRoutine in routinesDictionary {
                    let date = dailyRoutine.key
                    let routine = dailyRoutine.value.routine.map({ $0.toNewRoutine() })
                    self.routines[date] = routine
                }
            } catch {

            }
        }
    }

    // 현재 주의 첫째 날을 계산해줍니다.
    private func calculateWeekStartDate(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }

    private func fetchDailyRoutine() {
        let date = selectedDateSubject.value
        let dateKey = date.convertToString(dateType: .yearMonthDate)

        guard let dailyRoutines = routines[dateKey] else {
            routinesSubject.send([])
            return
        }

        routinesSubject.send(dailyRoutines)
    }
}
