//
//  ResultRecommendedRoutineViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import Combine
import Domain
import Foundation
import Shared

final class ResultRecommendedRoutineViewModel: ViewModel {
    enum ResultRecommendedRoutineViewModelType {
        case onboarding(onboardingEntity: OnboardingEntity)
        case mypage(onboardingEntity: OnboardingEntity)
        case emotion(emotion: Emotion)
    }
    
    enum Input {
        case fetchResultRecommendedRoutines
        case fetchSelectedRoutineId
        case selectRecommendedRoutine(routine: RecommendedRoutine)
        case registerRecommendedRoutine
        case showRecommendedRoutineToastMessageView
    }

    struct Output {
        let resultRecommendedRoutinesPublisher: AnyPublisher<[RecommendedRoutine], Never>
        let selectedRoutineIdPublisher: AnyPublisher<Int?, Never>
        let selectedRecommendedRoutinePublisher: AnyPublisher<Set<RecommendedRoutine>, Never>
        let confirmButtonPublisher: AnyPublisher<Bool, Never>
        let registerRoutineResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let resultRecommendedRoutinesSubject = CurrentValueSubject<[RecommendedRoutine], Never>([])
    private let selectedRoutineIdSubject = PassthroughSubject<Int?, Never>()
    private let selectedRecommendedRoutineSubject = CurrentValueSubject<Set<RecommendedRoutine>, Never>([])
    private let confirmButtonSubject = PassthroughSubject<Bool, Never>()
    private let registerRoutineResultSubject = PassthroughSubject<Bool, Never>()

    private var viewModelType: ResultRecommendedRoutineViewModelType?
    private let resultRecommendedRoutineUseCase: ResultRecommendedRoutineUseCaseProtocol
    init(resultRecommendedRoutineUseCase: ResultRecommendedRoutineUseCaseProtocol) {
        self.resultRecommendedRoutineUseCase = resultRecommendedRoutineUseCase
        output = Output(
            resultRecommendedRoutinesPublisher: resultRecommendedRoutinesSubject.eraseToAnyPublisher(),
            selectedRoutineIdPublisher: selectedRoutineIdSubject.eraseToAnyPublisher(),
            selectedRecommendedRoutinePublisher: selectedRecommendedRoutineSubject.eraseToAnyPublisher(),
            confirmButtonPublisher: confirmButtonSubject.eraseToAnyPublisher(),
            registerRoutineResultPublisher: registerRoutineResultSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .fetchResultRecommendedRoutines:
            fetchResultRecommendedRoutines()

        case .fetchSelectedRoutineId:
            let routineId = selectedRecommendedRoutineSubject.value.first?.id
            selectedRoutineIdSubject.send(routineId)

        case .selectRecommendedRoutine(let routine):
            selectRecommendedRoutine(routine: routine)

        case .registerRecommendedRoutine:
            registerRecommendedRoutine()

        case .showRecommendedRoutineToastMessageView:
            showRecommendedRoutineToastMessageView()
        }
    }

    // ViewModelType의 설정합니다. (setter)
    func configure(viewModelType: ResultRecommendedRoutineViewModelType) {
        self.viewModelType = viewModelType
    }

    // 추천 루틴 결과를 불러옵니다. (viewModelType에 따른 분기 처리)
    private func fetchResultRecommendedRoutines() {
        Task {
            do {
                switch viewModelType {
                case .onboarding(let onboardingEntity):
                    try await fetchResultRecommendedRoutines(onboardingEntity: onboardingEntity)

                case .mypage(let onboardingEntity):
                    try await fetchResultRecommendedRoutines(onboardingEntity: onboardingEntity)

                case .emotion(let emotion):
                    try await fetchResultRecommendedRoutines(emotion: emotion)

                case nil:
                    fatalError("ResultRecommendedRoutineViewModel Type이 설정되지 않았습니다.")
                }
            } catch {
                // TODO: 에러 처리
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    // 온보딩 · 목표 선택지를 등록하고 그에 따른 추천 루틴 결과를 불러옵니다.
    private func fetchResultRecommendedRoutines(onboardingEntity: OnboardingEntity) async throws {
        let entities = try await resultRecommendedRoutineUseCase.fetchResultRecommendedRoutines(onboardingEntity: onboardingEntity)
        let recommendedRoutines = entities.map({ $0.toRecommendedRoutine() })
        resultRecommendedRoutinesSubject.send([])
        resultRecommendedRoutinesSubject.send(recommendedRoutines)
    }

    // 감정구슬을 등록하고 그에 따른 추천 루틴 결과를 불러옵니다.
    private func fetchResultRecommendedRoutines(emotion: Emotion) async throws {
        let entities = try await resultRecommendedRoutineUseCase.fetchResultRecommendedRoutines(emotion: emotion.emotionType)
        let recommendedRoutines = entities.map({ $0.toRecommendedRoutine() })
        resultRecommendedRoutinesSubject.send([])
        resultRecommendedRoutinesSubject.send(recommendedRoutines)
    }

    private func resetResultRecommendedRoutines() {
        resultRecommendedRoutinesSubject.send([])
    }

    // 추천 루틴을 선택합니다.
    private func selectRecommendedRoutine(routine: RecommendedRoutine) {
        var selectedRoutines = selectedRecommendedRoutineSubject.value
        if selectedRoutines.contains(routine) {
            selectedRoutines.remove(routine)
        } else {
            if case .mypage = viewModelType {
                selectedRoutines.removeAll()
            }
            selectedRoutines.insert(routine)
        }
        selectedRecommendedRoutineSubject.send(selectedRoutines)
        updateRegisterButtonSubject()
    }


    // 등록하기 버튼 상태를 업데이트 합니다. (온보딩, 감정구슬 시에만 작동)
    private func updateRegisterButtonSubject() {
        let result = !selectedRecommendedRoutineSubject.value.isEmpty
        confirmButtonSubject.send(result)
    }

    // 추천 루틴을 등록합니다.
    private func registerRecommendedRoutine() {
        let selectedRoutinesId = selectedRecommendedRoutineSubject.value.map({ $0.id })
        Task {
            do {
                try await resultRecommendedRoutineUseCase.registerRecommendedRoutines(selectedRoutines: selectedRoutinesId)
                registerRoutineResultSubject.send(true)
            } catch {
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
                registerRoutineResultSubject.send(false)
            }
        }
    }

    private func showRecommendedRoutineToastMessageView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: .showRecommendedRoutineToast,
                object: nil,
                userInfo: nil)
        }
    }
}
