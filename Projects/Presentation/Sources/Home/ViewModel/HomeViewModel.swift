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
        case fetchEmotion
    }

    struct Output {
        let nicknamePublisher: AnyPublisher<String, Never>
        let fetchRoutineResultPublisher: AnyPublisher<Bool, Never>
        let routinesPublisher: AnyPublisher<[MainRoutine], Never>
        let emotionPublisher: AnyPublisher<Emotion?, Never>
    }

    private(set) var output: Output
    private var routines: [String: [MainRoutine]] = [:]
    private let nicknameSubject = CurrentValueSubject<String, Never>("")
    private let fetchRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let routinesSubject = CurrentValueSubject<[MainRoutine], Never>([])
    private let emotionSubject = CurrentValueSubject<Emotion?, Never>(nil)

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
            fetchRoutineResultPublisher: fetchRoutineResultSubject.eraseToAnyPublisher(),
            routinesPublisher: routinesSubject.eraseToAnyPublisher(),
            emotionPublisher: emotionSubject.eraseToAnyPublisher()
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

        case .fetchEmotion:
            fetchEmotion()
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

    // 필요 시, 루틴 데이터를 불러옵니다. (+- 주)
    private func calculateDate(for date: Date, offset week: Int) -> Date {
        let endDate = calendar.date(byAdding: .weekOfYear, value: week, to: date) ?? date
        return endDate
    }
}
