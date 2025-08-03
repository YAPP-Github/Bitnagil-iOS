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
    enum RepeatType {
        case daily
        case week
    }

    enum RoutineExample: String, CaseIterable {
        case wakeUp = "아침에 개운하게 일어나기"
        case foldBlanket = "일어나자마자 이불 개기"
        case drinkWater = "일어나서 찬물 마시기"
        case washFace = "세수하기"
    }

    enum ExecutionType: Comparable {
        case time(startAt: Date)
        case allDay
        case none

        var description: String {
            switch self {
            case .time(let time):
                return time.convertToString(dateType: .amPmTimeShort)
            case .allDay:
                return "하루종일"
            case .none:
                return "시간 선택"
            }
        }
    }

    enum Input {
        case fetchRoutine(id: String)
        case configureName(name: String)
        case addSubRoutine
        case deleteSubRoutine(index: Int)
        case configureSubRoutine(name: String, index: Int)
        case configureRepeatType(type: RepeatType)
        case toggleRepeatDay(weekDay: Week)
        case toggleRepeatAllDay
        case configureExecution(type: ExecutionType)
        case registerRoutine
    }

    struct Output {
        let namePublisher: AnyPublisher<String?, Never>
        let subRoutinesPublisher: AnyPublisher<[String], Never>
        let repeatTypePublisher: AnyPublisher<RepeatType?, Never>
        let weekDayPublisher: AnyPublisher<Set<Week>, Never>
        let executionTimePublisher: AnyPublisher<String, Never>
        let isRoutineValid: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let nameSubject = CurrentValueSubject<String?, Never>("")
    private let subRoutinesSubject = CurrentValueSubject<[SubRoutineSummaryEntity], Never>([])
    private let repeatTypeSubject = CurrentValueSubject<RepeatType?, Never>(nil)
    private let weekDaySubject = CurrentValueSubject<Set<Week>, Never>([])
    private let executionTimeSubject = CurrentValueSubject<ExecutionType, Never>(.none)
    private let checkRoutinePublisher = PassthroughSubject<Bool, Never>()
    private let routineUseCase: RoutineUseCaseProtocol
    private var deletedSubroutines = Set<SubRoutineSummaryEntity>()
    private var routineId: String?

    init(routineUseCase: RoutineUseCaseProtocol) {
        self.routineUseCase = routineUseCase

        output = Output(
            namePublisher: nameSubject.eraseToAnyPublisher(),
            subRoutinesPublisher: subRoutinesSubject
                .map { $0.compactMap { $0.subRoutineName } }
                .eraseToAnyPublisher(),
            repeatTypePublisher: repeatTypeSubject.eraseToAnyPublisher(),
            weekDayPublisher: weekDaySubject.eraseToAnyPublisher(),
            executionTimePublisher: executionTimeSubject
                .map{ $0.description }
                .eraseToAnyPublisher(),
            isRoutineValid: checkRoutinePublisher.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .fetchRoutine(let id):
            fetchRoutine(id: id)
        case .configureName(let name):
            configureName(name: name)
        case .addSubRoutine:
            addSubRoutine()
        case .deleteSubRoutine(let index):
            deleteSubRoutine(index: index)
        case .configureSubRoutine(let name, let index):
            configureSubroutine(name: name, index: index)
        case .configureRepeatType(let type):
            configureRepeatType(selectedType: type)
        case .toggleRepeatDay(let weekDay):
            configureWeekDay(weekDay: weekDay)
        case .toggleRepeatAllDay:
            configureExecutionTime(type: .allDay)
        case .configureExecution(let startTime):
            configureExecutionTime(type: startTime)
        case .registerRoutine:
            registerRoutine()
        }
        
        updateIsRoutineValid()
    }

    private func fetchRoutine(id: String) {
        Task {
            do {
                // TODO: - routine fetch 실패 시 처리 방안 필요 (기획과 논의~)
                guard let routine = try await routineUseCase.fetchRoutine(routineId: id) else { return }

                let subRoutines = routine.subRoutineSearchResultDto.map {
                    SubRoutineSummaryEntity(
                        subRoutineId: $0.subRoutineId,
                        subRoutineName: $0.subRoutineName,
                        sortOrder: $0.sortOrder)
                }
                let weekDay = routine.repeatDay.compactMap { Week(rawValue: $0.rawValue) }
                let repeatType: RepeatType = weekDay.count == Week.allCases.count ? .daily : .week
                let executionType: ExecutionType

                if routine.executionTime == "00:00:00" {
                    executionType = .allDay
                } else {
                    let time = Date.convertToDate(from: routine.executionTime, dateType: .amPmTimeShort)
                    executionType = .time(startAt: time ?? Date())
                }

                nameSubject.send(routine.routineName)
                subRoutinesSubject.send(subRoutines)
                weekDaySubject.send(Set(weekDay))
                repeatTypeSubject.send(repeatType)
                executionTimeSubject.send(executionType)
                routineId = id

                updateIsRoutineValid()
            } catch {
                // TODO: - 요기도 마찬가지 (ViewModel 공통 todo)
            }
        }
    }

    private func configureName(name: String) {
        nameSubject.send(name)
    }

    private func addSubRoutine() {
        var subRoutines = subRoutinesSubject.value
        guard subRoutines.count <= 3 else { return }

        let newSubRoutine = SubRoutineSummaryEntity(
            subRoutineId: nil,
            subRoutineName: "",
            sortOrder: subRoutines.count + 1)

        subRoutines.append(newSubRoutine)
        subRoutinesSubject.send(subRoutines)
    }

    private func deleteSubRoutine(index: Int) {
        var subRoutines = subRoutinesSubject.value
        guard
            index >= 0,
            index < subRoutines.count
        else { return }

        let targetSubRoutine = subRoutines[index]

        if targetSubRoutine.subRoutineId != nil {
            deletedSubroutines.insert(targetSubRoutine)
        }

        subRoutines.remove(at: index)
        subRoutinesSubject.send(subRoutines)
    }

    private func configureSubroutine(name: String, index: Int) {
        var subRoutines = subRoutinesSubject.value
        guard
            index >= 0,
            index < subRoutines.count
        else { return }

        let originalSubRoutine = subRoutines[index]
        let newSubRoutine = SubRoutineSummaryEntity(
            subRoutineId: originalSubRoutine.subRoutineId,
            subRoutineName: name,
            sortOrder: originalSubRoutine.sortOrder)
        subRoutines[index] = newSubRoutine

        subRoutinesSubject.send(subRoutines)
    }

    private func configureRepeatType(selectedType: RepeatType) {
        let repeatType = repeatTypeSubject.value

        switch selectedType {
        case .daily:
            weekDaySubject.send(Set(Week.allCases))
        case .week:
            if repeatType == .daily {
                weekDaySubject.send([])
            }
        }

        repeatTypeSubject.send(selectedType)
    }

    private func configureWeekDay(weekDay: Week) {
        var weekDays = weekDaySubject.value

        if weekDays.contains(weekDay) {
            weekDays.remove(weekDay)
        } else {
            weekDays.insert(weekDay)
        }

        weekDaySubject.send(weekDays)
    }

    private func configureExecutionTime(type: ExecutionType) {
        if
            type == .allDay,
            executionTimeSubject.value == .allDay
        {
            executionTimeSubject.send(.none)
            return
        }

        executionTimeSubject.send(type)
    }

    private func updateIsRoutineValid() {
        guard
            let name = nameSubject.value,
            !name.isEmpty,
            executionTimeSubject.value != .none,
            weekDaySubject.value.count > 0,
            subRoutinesSubject
                .value
                .map({$0.subRoutineName})
                .allSatisfy({$0?.isEmpty == false })
        else {
            checkRoutinePublisher.send(false)
            return
        }
        
        checkRoutinePublisher.send(true)
    }

    private func registerRoutine() {
        Task {
            do {
                let repeatDay = weekDaySubject
                    .value
                    .sorted(by: { $0.id < $1.id })
                    .map { $0.rawValue }

                let executionTime: String

                switch executionTimeSubject.value {
                case .time(let startAt):
                    executionTime = startAt.convertToString(dateType: .time)
                case .allDay:
                    executionTime = "00:00:00"
                case .none:
                    return
                }

                let routineSummary = RoutineSummaryEntity(
                    routineId: routineId,
                    routineName: nameSubject.value ?? "",
                    repeatDay: repeatDay,
                    executionTime: executionTime)

                try await routineUseCase.saveRoutine(
                    routineSummary: routineSummary,
                    subRoutineSummaries: subRoutinesSubject.value,
                    deletedSubRoutineSummaries: Array(deletedSubroutines))
            } catch {

            }
        }
    }
}
