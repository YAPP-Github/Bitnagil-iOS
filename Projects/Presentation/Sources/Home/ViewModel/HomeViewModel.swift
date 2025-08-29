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
        case fetchDailyRoutine
        case refreshDailyRoutine
        case updateRoutineCompletion(updatedRoutine: Routine)
        case fetchVersion
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let emotionPublisher: AnyPublisher<Emotion?, Never>
        let selectedDatePublisher: AnyPublisher<Date, Never>
        let routineListDatePublisher: AnyPublisher<Date, Never>
        let fetchRoutineResultPublisher: AnyPublisher<Bool, Never>
        let routinesPublisher: AnyPublisher<[Routine], Never>
        let updateRoutineCompletionResultPublisher: AnyPublisher<Bool, Never>
        let allCompletedRoutineDatePublisher: AnyPublisher<[Date], Never>
        let updateVersionPublisher: AnyPublisher<URL?, Never>
    }

    private(set) var output: Output
    private var routines: [String: [Routine]] = [:]
    private var routinesCompleted: [String: Bool] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let emotionSubject = CurrentValueSubject<Emotion?, Never>(nil)
    private let selectedDateSubject = CurrentValueSubject<Date, Never>(.now)
    private let routineListDateSubject = PassthroughSubject<Date, Never>()
    private let fetchRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let routinesSubject = CurrentValueSubject<[Routine], Never>([])
    private let selectedRoutineSubject = CurrentValueSubject<Routine?, Never>(nil)
    private let updateRoutineCompletionResultSubject = PassthroughSubject<Bool, Never>()
    private let allCompletedRoutineDateSubject = CurrentValueSubject<[Date], Never>([])
    private let updateVersionSubject = PassthroughSubject<URL?, Never>()

    private let calendar = Calendar.current
    private let today = Date()
    private var oldestDate: Date = Date()
    private var latestDate: Date = Date()

    private let routineUseCase: RoutineUseCaseProtocol
    private let userDataUseCase: UserDataUseCaseProtocol
    private let emotionUseCase: EmotionUseCaseProtocol
    private let appConfigRepository: AppConfigRepositoryProtocol

    init(
        routineUseCase: RoutineUseCaseProtocol,
        userDataUseCase: UserDataUseCaseProtocol,
        emotionUseCase: EmotionUseCaseProtocol,
        appConfigRepository: AppConfigRepositoryProtocol
    ) {
        self.routineUseCase = routineUseCase
        self.userDataUseCase = userDataUseCase
        self.emotionUseCase = emotionUseCase
        self.appConfigRepository = appConfigRepository
        self.output = Output(
            nicknamePublisher: nicknameSubject.eraseToAnyPublisher(),
            emotionPublisher: emotionSubject.eraseToAnyPublisher(),
            selectedDatePublisher: selectedDateSubject.eraseToAnyPublisher(),
            routineListDatePublisher: routineListDateSubject.eraseToAnyPublisher(),
            fetchRoutineResultPublisher: fetchRoutineResultSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher(),
            updateRoutineCompletionResultPublisher: updateRoutineCompletionResultSubject.eraseToAnyPublisher(),
            allCompletedRoutineDatePublisher: allCompletedRoutineDateSubject.eraseToAnyPublisher(),
            updateVersionPublisher: updateVersionSubject.eraseToAnyPublisher())
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

        case .fetchDailyRoutine:
            fetchDailyRoutine(for: selectedDateSubject.value)

        case .updateRoutineCompletion(let updatedRoutine):
            updateRoutineCompletion(updatedRoutine: updatedRoutine)

        case .refreshDailyRoutine:
            refreshSelectedDateRoutines()

        case .fetchVersion:
            checkVersion()
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
        guard let nextWeekDate = calendar.date(byAdding: .weekOfYear, value: week, to: currentDate)
        else { return }
        let weekStartDate = calculateWeekStartDate(for: nextWeekDate)
        selectedDateSubject.send(weekStartDate)
        fetchDailyRoutine(for: weekStartDate)
        fetchAllCompletedRoutine()
    }

    // 현재 주의 첫째 날(월요일)을 계산해줍니다.
    private func calculateWeekStartDate(for date: Date) -> Date {
        let weekday = calendar.component(.weekday, from: date)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.date(byAdding: .day, value: -daysFromMonday, to: date) ?? date
    }

    // 날짜를 선택하고 그 날에 해당하는 루틴을 불러옵니다.
    private func selectDate(date: Date) {
        selectedDateSubject.send(date)
        fetchDailyRoutine(for: date)
    }

    private func fetchAllCompletedRoutine() {
        let selectedDate = selectedDateSubject.value
        let weekStartDate = calculateWeekStartDate(for: selectedDate)
        var allCompletedDates: [Date] = []
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: weekStartDate)
            else { continue }
            guard
                let isAllCompleted = routinesCompleted[date.convertToString(dateType: .yearMonthDate)],
                isAllCompleted
            else { continue }
            allCompletedDates.append(date)
        }
        allCompletedRoutineDateSubject.send(allCompletedDates)
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

    // 서버로부터 루틴들을 불러옵니다. (루틴 조회 시작 날짜 ~ 루틴 조회 종료 날짜)
    private func fetchRoutines(startDate: Date, endDate: Date) {
        Task {
            do {
                let entities = try await routineUseCase.fetchRoutines(startDate: startDate, endDate: endDate)
                for (date, values) in entities {
                    let routineEntities = values.routines
                    let allCompleted = values.allCompleted
                    routines[date] = routineEntities.map({ $0.toRoutine() })
                    routinesCompleted[date] = allCompleted
                }
                fetchAllCompletedRoutine()
                fetchRoutineResultSubject.send(true)
            } catch {
                fetchRoutineResultSubject.send(false)
                // TODO: 에러 처리
            }
        }
    }

    // 특정 날짜에 대한 Routines 조회
    private func fetchDailyRoutine(for date: Date) {
        // 조회 성공
        if let dailyRoutines = routines[date.convertToString(dateType: .yearMonthDate)] {
            routinesSubject.send(dailyRoutines)
            return
        }

        // 이미 캐싱된 날짜이지만, 데이터가 없을 때 (루틴 없음)
        guard date < oldestDate || date > latestDate else {
            routinesSubject.send([])
            return
        }

        // 루틴 캐싱
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
            // 새로 캐싱된 루틴들에서 데이터가 있을 때,
            routinesSubject.send(dailyRoutines)
        } else {
            // 새로 캐싱된 루틴들에서 데이터가 없을 때,
            routinesSubject.send([])
        }
    }

    // 선택된 날의 루틴들을 재조회하여 업데이트 합니다.
    private func refreshSelectedDateRoutines() {
        let selectedDate = selectedDateSubject.value
        Task {
            fetchRoutines(startDate: selectedDate, endDate: selectedDate)
            fetchDailyRoutine(for: selectedDate)
            fetchAllCompletedRoutine()
        }
    }

    // 루틴의 완료 여부를 업데이트 합니다.
    private func updateRoutineCompletion(updatedRoutine: Routine) {
        Task {
            do {
                let routineEntity = updatedRoutine.toRoutineEntity()
                try await routineUseCase.updateRoutineCompletions(routines: [routineEntity])
                updateRoutineCompletionResultSubject.send(true)
            } catch {
                // TODO: 에러 처리
            }
        }
    }

    private func checkVersion() {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let major = currentVersion?.split(separator: ".").first

        Task {
            do {
                let appStoreAppVersion = try await appConfigRepository.fetchAppVersion()
                let appStoreMajor = appStoreAppVersion?.split(separator: ".").first

                if major != appStoreMajor {
                    let url = URL(string: "itms-apps://itunes.apple.com/app/id6749437799")
                    updateVersionSubject.send(url)
                } else {
                    updateVersionSubject.send(nil)
                }

            } catch {

            }
        }
    }
}
