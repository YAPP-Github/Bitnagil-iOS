//
//  RoutineCreationViewModel.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//
import Combine
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
    private let subRoutinesSubject = CurrentValueSubject<[String], Never>([])
    private let repeatTypeSubject = CurrentValueSubject<RepeatType?, Never>(nil)
    private let weekDaySubject = CurrentValueSubject<Set<Week>, Never>([])
    private let executionTimeSubject = CurrentValueSubject<ExecutionType, Never>(.none)
    private let checkRoutinePublisher = PassthroughSubject<Bool, Never>()

    init() {
        output = Output(
            namePublisher: nameSubject.eraseToAnyPublisher(),
            subRoutinesPublisher: subRoutinesSubject.eraseToAnyPublisher(),
            repeatTypePublisher: repeatTypeSubject.eraseToAnyPublisher(),
            weekDayPublisher: weekDaySubject.eraseToAnyPublisher(),
            executionTimePublisher: executionTimeSubject
                .map{ $0.description }
                .eraseToAnyPublisher(),
            isRoutineValid: checkRoutinePublisher.eraseToAnyPublisher())
    }

    func action(input: Input) {
        switch input {
        case .configureName(let name):
            configureName(name: name)
        case .addSubRoutine:
            addSubRoutine()
        case .deleteSubRoutine(let index):
            deleteSubRoutine(index: index)
        case .configureSubRoutine(let name, let index):
            configureSubroutine(name: name, index: index)
        case .configureRepeatType(let type):
            configureRepeatType(type: type)
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

    private func configureName(name: String) {
        nameSubject.send(name)
    }

    private func addSubRoutine() {
        var subRoutines = subRoutinesSubject.value
        guard subRoutines.count <= 3 else { return }

        subRoutines.append("")
        subRoutinesSubject.send(subRoutines)
    }

    private func deleteSubRoutine(index: Int) {
        var subRoutines = subRoutinesSubject.value
        guard
            index >= 0,
            index < subRoutines.count
        else { return }

        subRoutines.remove(at: index)
        subRoutinesSubject.send(subRoutines)
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

    private func configureRepeatType(type: RepeatType) {
        var repeatType = repeatTypeSubject.value

        repeatType = repeatType == type
            ? nil
            : type

        if repeatType != .week {
            weekDaySubject.send([])
        }
        repeatTypeSubject.send(repeatType)
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
            executionTimeSubject.value != .none
        else {
            checkRoutinePublisher.send(false)
            return
        }
        
        checkRoutinePublisher.send(true)
    }

    private func registerRoutine() {
        // API 호출
    }
}
