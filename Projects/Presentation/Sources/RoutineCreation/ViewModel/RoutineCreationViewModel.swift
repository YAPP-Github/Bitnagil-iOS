//
//  RoutineCreationViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//

import Combine
import Domain
import Foundation

final class RoutineCreationViewModel: ViewModel {
    enum UpdateType {
        case today
        case tomorrow
    }

    struct ExecutionTime {
        let startAt: Date?
    }

    enum Input {
        case fetchRoutine(id: String)
        case fetchRecommendedRoutine(id: Int)
        case configureName(name: String)
        case deleteAllSubRoutines
        case configureSubRoutine(name: String, index: Int)
        case configureRepeatType(type: RepeatType)
        case configureRepeatWeeks(weeks: [Week])
        case toggleAllDay
        case configureStartDate(date: Date)
        case configureEndDate(date: Date)
        case configureExecution(type: ExecutionTime)
        case registerRoutine
    }

    struct Output {
        let namePublisher: AnyPublisher<String?, Never>
        let subRoutinesPublisher: AnyPublisher<[String], Never>
        let repeatTypePublisher: AnyPublisher<RepeatType?, Never>
        let periodPublisher: AnyPublisher<(Date, Date), Never>
        let executionTimePublisher: AnyPublisher<Date?, Never>
        let isRoutineValid: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let nameSubject = CurrentValueSubject<String?, Never>("")
    private let subRoutinesSubject = CurrentValueSubject<[String], Never>([])
    private let repeatTypeSubject = CurrentValueSubject<RepeatType?, Never>(nil)
    private let periodStartSubject = CurrentValueSubject<Date, Never>(Date())
    private let periodEndSubject   = CurrentValueSubject<Date, Never>(Date())
    private let executionTimeSubject = CurrentValueSubject<ExecutionTime, Never>(.init(startAt: nil))
    private let checkRoutinePublisher = PassthroughSubject<Bool, Never>()
    private let routineUseCase: RoutineUseCaseProtocol
    private let recommenededRoutineUseCase: RecommendedRoutineUseCaseProtocol
    private var deletedSubroutines = Set<SubRoutineSummaryEntity>()
    private var routineId: String?

    init(routineUseCase: RoutineUseCaseProtocol, recommenededRoutineUseCase: RecommendedRoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase
        self.recommenededRoutineUseCase = recommenededRoutineUseCase

        output = Output(
            namePublisher: nameSubject.eraseToAnyPublisher(),
            subRoutinesPublisher: subRoutinesSubject.eraseToAnyPublisher(),
            repeatTypePublisher: repeatTypeSubject.eraseToAnyPublisher(),
            periodPublisher: Publishers
                .CombineLatest(periodStartSubject, periodEndSubject)
                .map { ($0, $1) }
                .eraseToAnyPublisher(),
            executionTimePublisher: executionTimeSubject
                .map { $0.startAt }
                .eraseToAnyPublisher(),
            isRoutineValid: checkRoutinePublisher.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchRoutine(let id):
            fetchRoutine(id: id)
        case .fetchRecommendedRoutine(let id):
            fetchRecommendedRoutine(id: id)
        case .configureName(let name):
            configureName(name: name)
        case .deleteAllSubRoutines:
            subRoutinesSubject.send(["", "", ""])
        case .configureSubRoutine(let name, let index):
            configureSubroutine(name: name, index: index)
        case .configureRepeatType(let type):
            configureRepeatType(selectedType: type)
        case .configureRepeatWeeks(let weeks):
            configureWeeks(weeks: weeks)
        case .toggleAllDay:
            let midnight = Calendar.current.startOfDay(for: Date())
            configureExecutionTime(time: .init(startAt: midnight))
        case .configureExecution(let startTime):
            configureExecutionTime(time: startTime)
        case .registerRoutine:
            registerRoutine()
        case .configureStartDate(let date):
            periodStartSubject.send(date)
        case .configureEndDate(let date):
            periodEndSubject.send(date)
        }
        
        updateIsRoutineValid()
    }

    private func fetchRoutine(id: String) {
        Task {
            do {
                // TODO: - routine fetch 실패 시 처리 방안 필요 (기획과 논의~)
                guard let routine = try await routineUseCase.fetchRoutine(routineId: id) else { return }

                let subRoutines = routine.subRoutineSearchResultDto.map { $0.subRoutineName }
                let weekDay = routine.repeatDay.compactMap { Week(rawValue: $0.rawValue) }
                let repeatType: RepeatType?

                if weekDay.isEmpty {
                    repeatType = nil
                } else if weekDay.count == Week.allCases.count {
                    repeatType = .daily
                } else {
                    repeatType = .weekly(weeks: Set(weekDay))
                }

                let executionType: ExecutionTime

                let time = Date.convertToDate(from: routine.executionTime, dateType: .amPmTimeShort)
                executionType = .init(startAt: time ?? Date())

                nameSubject.send(routine.routineName)
                subRoutinesSubject.send(subRoutines)
                repeatTypeSubject.send(repeatType)
                executionTimeSubject.send(executionType)
                routineId = id

                updateIsRoutineValid()
            } catch {
                // TODO: - 요기도 마찬가지 (ViewModel 공통 todo)
            }
        }
    }

    private func fetchRecommendedRoutine(id: Int) {
        Task {
            do {
                guard let routine = try await recommenededRoutineUseCase.fetchRecommendedRoutine(id: id) else { return }

                let subRoutines = routine.subRoutines.map { $0.title }

                nameSubject.send(routine.title)
                subRoutinesSubject.send(subRoutines)

                updateIsRoutineValid()
            } catch {
            }
        }
    }

    private func configureName(name: String) {
        nameSubject.send(name)
    }

    private func configureSubroutine(name: String, index: Int) {
        var subRoutines = subRoutinesSubject.value
        guard
            index >= 0,
            index < subRoutines.count
        else { return }

        subRoutines[index] = name
        subRoutinesSubject.send(subRoutines)
    }

    private func configureRepeatType(selectedType: RepeatType?) {
        let current = repeatTypeSubject.value

        switch selectedType {
        case .daily:
            if case .daily = current {
                repeatTypeSubject.send(nil)
            } else {
                repeatTypeSubject.send(.daily)
            }
        case .weekly:
            if case .weekly = current {
                repeatTypeSubject.send(nil)
            } else {
                repeatTypeSubject.send(.weekly(weeks: []))
            }
        case .none:
            repeatTypeSubject.send(nil)
        }
    }

    private func configureWeeks(weeks: [Week]) {
        guard case .weekly = repeatTypeSubject.value else { return }
        repeatTypeSubject.send(.weekly(weeks: Set(weeks)))
    }

    private func configureExecutionTime(time: ExecutionTime) {
        if
           let time = time.startAt,
           let curTime = executionTimeSubject.value.startAt,
           time.isMidnight,
           curTime.isMidnight
        {
            executionTimeSubject.send(.init(startAt: nil))
            return
        }

        executionTimeSubject.send(time)
    }

    private func updateIsRoutineValid() {
        guard
            let name = nameSubject.value,
            !name.isEmpty,
            executionTimeSubject.value.startAt != nil
        else {
            checkRoutinePublisher.send(false)
            return
        }
        
        checkRoutinePublisher.send(true)
    }

    private func registerRoutine() {
        Task {
            do {

                let repeatDay: [String]

                switch repeatTypeSubject.value {
                case .daily:
                    repeatDay = Week.allCases.map { $0.rawValue }
                case .weekly(let weeks):
                    repeatDay = weeks.map { $0.rawValue }
                case .none:
                    repeatDay = []
                }

                guard let startAt = executionTimeSubject.value.startAt else { return }

                let executionTime = startAt.convertToString(dateType: .time)

                let routineSummary = RoutineSummaryEntity(
                    routineId: routineId,
                    routineName: nameSubject.value ?? "",
                    repeatDay: repeatDay,
                    executionTime: executionTime)

                try await routineUseCase.saveRoutine(
                    routineSummary: routineSummary,
                    subRoutineSummaries: [], // TODO: - 수정 필요
                    deletedSubRoutineSummaries: Array(deletedSubroutines))
            } catch {

            }
        }
    }
}
