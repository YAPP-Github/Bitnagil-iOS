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
        case configureUpdateType(updateType: RoutineUpdateApplyDateType)
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
        let periodPublisher: AnyPublisher<(Date?, Date?), Never>
        let executionTimePublisher: AnyPublisher<Date?, Never>
        let isRoutineValid: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let nameSubject = CurrentValueSubject<String?, Never>("")
    private let subRoutinesSubject = CurrentValueSubject<[String], Never>(["", "", ""])
    private let repeatTypeSubject = CurrentValueSubject<RepeatType?, Never>(nil)
    private let periodStartSubject = CurrentValueSubject<Date?, Never>(nil)
    private let periodEndSubject   = CurrentValueSubject<Date?, Never>(nil)
    private let executionTimeSubject = CurrentValueSubject<ExecutionTime, Never>(.init(startAt: nil))
    private let checkRoutinePublisher = CurrentValueSubject<Bool, Never>(false)
    private let routineUseCase: RoutineUseCaseProtocol
    private let recommenededRoutineUseCase: RecommendedRoutineUseCaseProtocol
    private var deletedSubroutines = Set<SubRoutineSummaryEntity>()
    private var routineId: String?
    private var routineType: RoutineCategoryType?
    private var updateType: RoutineUpdateApplyDateType?

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
        
        updateIsRoutineValid()
    }

    func action(input: Input) {
        switch input {
        case .configureUpdateType(let updateType):
            self.updateType = updateType
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

                let subRoutines = routine.subRoutineNames
                let weekDay = routine.repeatDay.compactMap { Week(rawValue: $0) }
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

                // TODO: - routine 엔티티 변경 이후 시작일자, 종료 일자 설정 필요 + 추천 타입 있으면 추천 타입도 설정 필요

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
                routineType = routine.type

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
            executionTimeSubject.value.startAt != nil,
            periodStartSubject.value != nil,
            periodEndSubject.value != nil
        else {
            checkRoutinePublisher.send(false)
            return
        }
        
        checkRoutinePublisher.send(true)
    }

    private func registerRoutine() {
        Task {
            do {
                guard
                    let name = nameSubject.value,
                    let startDate = periodStartSubject.value,
                    let endDate = periodEndSubject.value,
                    let executionTime = executionTimeSubject.value.startAt
                else { return }
                
                let repeatDay: [Week]
                let startDateString = startDate.convertToString(dateType: .yearMonthDate)
                let endDateString = endDate.convertToString(dateType: .yearMonthDate)
                let executionTimeString = executionTime.convertToString(dateType: .time)

                switch repeatTypeSubject.value {
                case .daily:
                    repeatDay = Week.allCases
                case .weekly(let weeks):
                    repeatDay = weeks.sorted { $0.id < $1.id }
                case .none:
                    repeatDay = []
                }

                let routine = RoutineCreationEntity(
                    id: routineId,
                    name: name,
                    repeatDay: repeatDay,
                    startDate: startDateString,
                    endDate: endDateString,
                    executionTime: executionTimeString,
                    subroutines: subRoutinesSubject.value,
                    recommendedRoutineType: routineType,
                    applyDateType: updateType)

                try await routineUseCase.saveRoutine(routine: routine)
            } catch {

            }
        }
    }
}
