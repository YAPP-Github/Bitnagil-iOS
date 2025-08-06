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
        case loadEmotion
        case selectDate(date: Date)
        case fetchRoutines
        case selectRoutine(routine: MainRoutine?)
        case deleteDailyRoutine
        case deleteAllRoutine
        case refreshSelectedDateRoutine
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let emotionPublisher: AnyPublisher<Emotion?, Never>
        let selectedDatePublisher: AnyPublisher<Date, Never>
        let fetchRoutineResultPublisher: AnyPublisher<Bool, Never>
        let routinesPublisher: AnyPublisher<[MainRoutine], Never>
        let deleteRoutineResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private var routines: [String: [MainRoutine]] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let emotionSubject = CurrentValueSubject<Emotion?, Never>(nil)
    private let selectedDateSubject = CurrentValueSubject<Date, Never>(.now)
    private let fetchRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let routinesSubject = CurrentValueSubject<[MainRoutine], Never>([])
    private let selectedRoutineSubject = CurrentValueSubject<MainRoutine?, Never>(nil)
    private let deleteRoutineResultSubject = PassthroughSubject<Bool, Never>()

    private let calendar = Calendar.current
    private let today = Date()
    private var oldestDate: Date = Date()
    private var latestDate: Date = Date()

    private let routineUseCase: RoutineUseCaseProtocol
    private let userDataUseCase: UserDataUseCaseProtocol
    private let emotionUseCase: EmotionUseCaseProtocol
    init(
        routineUseCase: RoutineUseCaseProtocol,
        userDataUseCase: UserDataUseCaseProtocol,
        emotionUseCase: EmotionUseCaseProtocol
    ) {
        self.routineUseCase = routineUseCase
        self.userDataUseCase = userDataUseCase
        self.emotionUseCase = emotionUseCase
        self.output = Output(
            nicknamePublisher: nicknameSubject.eraseToAnyPublisher(),
            emotionPublisher: emotionSubject.eraseToAnyPublisher(),
            selectedDatePublisher: selectedDateSubject.eraseToAnyPublisher(),
            fetchRoutineResultPublisher: fetchRoutineResultSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher(),
            deleteRoutineResultPublisher: deleteRoutineResultSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .loadNickname:
            loadNickname()

        case .loadEmotion:
            fetchEmotion()

        case .selectDate(let date):
            selectDate(date: date)

        case .fetchRoutines:
            fetchRoutines()

        case .selectRoutine(let routine):
            selectedRoutineSubject.send(routine)

        case .deleteDailyRoutine:
            deleteDailyRoutine()

        case .deleteAllRoutine:
            deleteAllRoutine()

        case .refreshSelectedDateRoutine:
            fetchRoutines()
            fetchRoutines(for: selectedDateSubject.value)
        }
    }

    // MARK: - User 정보
    // 유저 닉네임을 불러옵니다.
    private func loadNickname() {
        Task {
            do {
                let nickname = try await userDataUseCase.loadNickname()
                nicknameSubject.send(nickname)
            } catch {
                
            }
        }
    }

    // 감정 구슬을 불러옵니다.
    private func fetchEmotion() {
        Task {
            do {
                let emotionEntity = try await emotionUseCase.fetchEmotion(date: today)
                let emotion = emotionEntity?.toEmotion()
                emotionSubject.send(emotion)
            } catch {

            }
        }
    }

    // MARK: - 루틴
    // 루틴들을 불러옵니다. (처음에는 +-1 주, 그 이후에는 1주씩)
    private func fetchRoutines() {
        var startDate = oldestDate
        var endDate = latestDate

        if routines.isEmpty {
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: today) ?? today
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today

            oldestDate = startDate
            latestDate = endDate
        }

        Task {
            do {
                let entities = try await routineUseCase.fetchRoutines(startDate: startDate, endDate: endDate)
                for (date, routineEntities) in entities {
                    routines[date] = routineEntities.compactMap({ $0.toMainRoutine() })
                }
                fetchRoutineResultSubject.send(true)
            } catch {

            }
        }
    }

    // 날짜를 선택하고 그 날에 해당하는 루틴을 불러옵니다.
    private func selectDate(date: Date) {
        selectedDateSubject.send(date)
        fetchRoutines(for: date)
    }

    // 선택한 날의 루틴을 필터링하여 보여줍니다. (oldestDate, latestDate 업데이트)
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

    // 반복 루틴을 삭제합니다.
    private func deleteAllRoutine() {
        guard let routineId = selectedRoutineSubject.value?.id
        else { return }

        Task {
            do {
                try await routineUseCase.deleteAllRoutine(routineId: routineId)
                selectedRoutineSubject.send(nil)
                deleteRoutineResultSubject.send(true)
            } catch {
                deleteRoutineResultSubject.send(false)
            }
        }
    }

    // 당일 루틴을 삭제합니다.
    private func deleteDailyRoutine() {
        guard let routine = selectedRoutineSubject.value
        else { return }

        let deleteSubRoutineEntity = routine.subRoutines.map({
            DeleteSubRoutineEntity(subRoutineId: $0.id, routineCompletionId: $0.completionId) })
        let deleteRoutinEntity = DeleteRoutineEntity(
            routineId: routine.id,
            routineCompletionId: routine.completionId,
            historySeq: routine.historySeq,
            performedDate: selectedDateSubject.value.convertToString(dateType: .yearMonthDate),
            routineType: routine.routineType,
            subRoutineInfosForDelete: deleteSubRoutineEntity)

        Task {
            do {
                try await routineUseCase.deleteDailyRoutine(routine: deleteRoutinEntity)
                deleteRoutineResultSubject.send(true)
            } catch {
                deleteRoutineResultSubject.send(false)
            }
        }
    }
}
