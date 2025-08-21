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
        case moveWeek(week: Int)
        case selectDate(date: Date)
        case selectRoutineListDate
        case fetchRoutines
        case selectRoutine(routine: Routine?)
        case updateRoutineCompletion(updatedRoutine: Routine)
        case refreshSelectedDateRoutine
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let emotionPublisher: AnyPublisher<Emotion?, Never>
        let selectedDatePublisher: AnyPublisher<Date, Never>
        let routineListDatePublisher: AnyPublisher<Date, Never>
        let fetchRoutineResultPublisher: AnyPublisher<Bool, Never>
        let routinesPublisher: AnyPublisher<[Routine], Never>
        let updateRoutineCompletionResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private var routines: [String: [Routine]] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let emotionSubject = CurrentValueSubject<Emotion?, Never>(nil)
    private let selectedDateSubject = CurrentValueSubject<Date, Never>(.now)
    private let routineListDateSubject = PassthroughSubject<Date, Never>()
    private let fetchRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let routinesSubject = CurrentValueSubject<[Routine], Never>([])
    private let selectedRoutineSubject = CurrentValueSubject<Routine?, Never>(nil)
    private let updateRoutineCompletionResultSubject = PassthroughSubject<Bool, Never>()

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
            routineListDatePublisher: routineListDateSubject.eraseToAnyPublisher(),
            fetchRoutineResultPublisher: fetchRoutineResultSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher(),
            updateRoutineCompletionResultPublisher: updateRoutineCompletionResultSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .loadNickname:
            loadNickname()

        case .loadEmotion:
            fetchEmotion()

        case .moveWeek(let week):
            moveWeek(by: week)

        case .selectDate(let date):
            selectDate(date: date)

        case .selectRoutineListDate:
            let selectedDate = selectedDateSubject.value
            routineListDateSubject.send(selectedDate)

        case .fetchRoutines:
            fetchRoutines()

        case .selectRoutine(let routine):
            selectedRoutineSubject.send(routine)

        case .updateRoutineCompletion(let updatedRoutine):
            updateRoutineCompletion(updatedRoutine: updatedRoutine)

        case .refreshSelectedDateRoutine:
            fetchDailyRoutine(for: selectedDateSubject.value)
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
                let emotionEntity = try await emotionUseCase.loadEmotion(date: today)
                let emotion = emotionEntity?.toEmotion()
                emotionSubject.send(emotion)
            } catch {

            }
        }
    }

    // MARK: - 날짜
    private func moveWeek(by week: Int) {
        let currentDate = selectedDateSubject.value
        guard let weekStartDate = calendar.date(byAdding: .weekOfYear, value: week, to: currentDate)
        else { return }
        selectedDateSubject.send(weekStartDate)
    }

    // MARK: - 루틴
    // 루틴들을 불러옵니다. (처음에는 +-1 주, 그 이후에는 1주씩)
    private func fetchRoutines() {
        if routines.isEmpty {
            oldestDate = calendar.date(byAdding: .weekOfYear, value: -1, to: today) ?? today
            latestDate = calendar.date(byAdding: .weekOfYear, value: 1, to: today) ?? today
        }
        fetchRoutines(startDate: oldestDate, endDate: latestDate)
    }

    // 날짜를 선택하고 그 날에 해당하는 루틴을 불러옵니다.
    private func selectDate(date: Date) {
        selectedDateSubject.send(date)
        fetchRoutines()
        fetchDailyRoutine(for: date)
    }

    private func fetchDailyRoutine(for date: Date) {
        if let dailyRoutines = routines[date.convertToString(dateType: .yearMonthDate)] {
            routinesSubject.send(dailyRoutines)
            return
        }

        var startDate: Date = Date()
        var endDate: Date = Date()
        if date < oldestDate {
            // 캐싱된 데이터보다 이전의 날짜 조회 시,
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: oldestDate) ?? oldestDate
            endDate = calendar.date(byAdding: .day, value: -1, to: oldestDate) ?? oldestDate
            oldestDate = startDate
        } else if date > latestDate {
            // 캐싱된 데이터보다 이후의 날짜 조회 시,
            startDate = calendar.date(byAdding: .day, value: 1, to: latestDate) ?? latestDate
            endDate = calendar.date(byAdding: .weekOfYear, value: 1, to: latestDate) ?? latestDate
            latestDate = endDate
        }
        fetchRoutines(startDate: startDate, endDate: endDate)

        if let dailyRoutines = routines[date.convertToString(dateType: .yearMonthDate)] {
            routinesSubject.send(dailyRoutines)
            return
        } else {
            routinesSubject.send([])
        }
    }

    // 서버로부터 루틴들을 불러옵니다.. (루틴 조회 시작 날짜 ~ 루틴 조회 종료 날짜)
    private func fetchRoutines(startDate: Date, endDate: Date) {
        Task {
            do {
                let entities = try await routineUseCase.fetchRoutines(startDate: startDate, endDate: endDate)
                for (date, values) in entities {
                    let routineEntities = values.routines
                    routines[date] = routineEntities.compactMap({ $0.toRoutine() })
                }
                fetchRoutineResultSubject.send(true)
            } catch {
                // TODO: 에러 처리
            }
        }
    }

    // 루틴의 완료 여부를 업데이트 합니다.
    private func updateRoutineCompletion(updatedRoutine: Routine) {
        /*
        let performedDate = selectedDateSubject.value.convertToString(dateType: .yearMonthDate)
        var routineCompletionEntities: [RoutineCompletionEntity] = []

        let isDone = !updatedRoutine.isDone
        let routineCompletionEntity = RoutineCompletionEntity(
            performedDate: performedDate,
            routineId: updatedRoutine.id,
            completeYn: isDone,
            historySeq: updatedRoutine.historySeq,
            routineType: updatedRoutine.routineType)
        routineCompletionEntities.append(routineCompletionEntity)

        // 메인 루틴이라면, 그 안의 세부 루틴 값도 업데이트
        if let mainRoutine = updatedRoutine as? MainRoutine {
            for subRoutine in mainRoutine.subRoutines {
                guard subRoutine.isDone != isDone else { continue }
                let subRoutineCompletionEntity = RoutineCompletionEntity(
                    performedDate: performedDate,
                    routineId: subRoutine.id,
                    completeYn: isDone,
                    historySeq: subRoutine.historySeq,
                    routineType: subRoutine.routineType)
                routineCompletionEntities.append(subRoutineCompletionEntity)
            }
        } else if let subRoutine = updatedRoutine as? SubRoutine {
            // 세부 루틴이라면, 세부 루틴의 완료 값을 확인하여 메인 루틴도 업데이트
            let mainRoutines = routinesSubject.value
            for mainRoutine in mainRoutines {
                if mainRoutine.subRoutines.contains(subRoutine) {
                    let mainRoutineIsDone = mainRoutine.isDone
                    var subRoutineCompleted: Bool
                    if subRoutine.isDone {
                        subRoutineCompleted = mainRoutine.subRoutines.filter({ $0.isDone }).count - 1 == mainRoutine.subRoutines.count
                    } else {
                        subRoutineCompleted = mainRoutine.subRoutines.filter({ $0.isDone }).count + 1 == mainRoutine.subRoutines.count
                    }
                    if subRoutineCompleted != mainRoutineIsDone {
                        let mainRoutineCompletionEntity = RoutineCompletionEntity(
                            performedDate: performedDate,
                            routineId: mainRoutine.id,
                            completeYn: subRoutineCompleted,
                            historySeq: mainRoutine.historySeq,
                            routineType: mainRoutine.routineType)
                        routineCompletionEntities.append(mainRoutineCompletionEntity)
                    }
                }
            }
        }

        Task {
            do {
                try await routineUseCase.updateRoutineCompletions(routines: routineCompletionEntities)
                updateRoutineCompletionResultSubject.send(true)
                fetchRoutines()
            } catch {
                updateRoutineCompletionResultSubject.send(false)
            }
        }
         */
    }
}
