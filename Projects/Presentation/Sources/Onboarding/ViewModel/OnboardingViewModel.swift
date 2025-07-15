//
//  OnboardingViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import Combine
import Domain
import Shared

final class OnboardingViewModel: ViewModel {
    enum Input {
        case selectOnboardingChoice(selectedChoice: OnboardingChoiceType)
        case fetchOnboardingChoice(onboarding: OnboardingType)
        case makeOnboardingResult
        case registerOnboarding
        case selectRoutine(routine: RecommendedRoutine)
        case registerRecommendedRoutine
    }

    struct Output {
        let timeOnboardingChoicePublisher: AnyPublisher<OnboardingChoiceType?, Never>
        let frequencyOnboardingChoicePublisher: AnyPublisher<OnboardingChoiceType?, Never>
        let feelingOnboardingChoicePublisher: AnyPublisher<Set<OnboardingChoiceType>, Never>
        let outdoorOnboardingChoicePublisher: AnyPublisher<OnboardingChoiceType?, Never>
        let onboardingResultPublisher: AnyPublisher<[String], Never>
        let recommendedRoutinePublisher: AnyPublisher<Set<RecommendedRoutine>, Never>
        let selectedRoutinePublisher: AnyPublisher<Set<RecommendedRoutine>, Never>
        let registerRoutineResultPublisher: AnyPublisher<Bool, Never>
        let nextButtonPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let timeOnboardingChoiceSubject = CurrentValueSubject<OnboardingChoiceType?, Never>(nil)
    private let frequencyOnboardingChoiceSubject = CurrentValueSubject<OnboardingChoiceType?, Never>(nil)
    private let feelingOnboardingChoiceSubject = CurrentValueSubject<Set<OnboardingChoiceType>, Never>([])
    private let outdoorOnboardingChoiceSubject = CurrentValueSubject<OnboardingChoiceType?, Never>(nil)
    private let onboardingResultSubject = CurrentValueSubject<[String], Never>([])
    private let recommendedRoutineSubject = CurrentValueSubject<Set<RecommendedRoutine>, Never>([])
    private let selectedRoutineSubject = CurrentValueSubject<Set<RecommendedRoutine>, Never>([])
    private let registerRoutineResultSubject = PassthroughSubject<Bool, Never>()
    private let nextButtonSubject = PassthroughSubject<Bool, Never>()

    private let onboardingUseCase: OnboardingUseCaseProtocol
    init(onboardingUseCase: OnboardingUseCaseProtocol) {
        self.onboardingUseCase = onboardingUseCase
        self.output = Output(
            timeOnboardingChoicePublisher: timeOnboardingChoiceSubject.eraseToAnyPublisher(),
            frequencyOnboardingChoicePublisher: frequencyOnboardingChoiceSubject.eraseToAnyPublisher(),
            feelingOnboardingChoicePublisher: feelingOnboardingChoiceSubject.eraseToAnyPublisher(),
            outdoorOnboardingChoicePublisher: outdoorOnboardingChoiceSubject.eraseToAnyPublisher(),
            onboardingResultPublisher: onboardingResultSubject.eraseToAnyPublisher(),
            recommendedRoutinePublisher: recommendedRoutineSubject.eraseToAnyPublisher(),
            selectedRoutinePublisher: selectedRoutineSubject.eraseToAnyPublisher(),
            registerRoutineResultPublisher: registerRoutineResultSubject.eraseToAnyPublisher(),
            nextButtonPublisher: nextButtonSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .selectOnboardingChoice(let selectedChoice):
            selectChoice(choice: selectedChoice)

        case .fetchOnboardingChoice(let onboarding):
            fetchChoice(onboarding: onboarding)

        case .makeOnboardingResult:
            makeOnboardingResult()

        case .registerOnboarding:
            registerOnboarding()

        case .selectRoutine(let routine):
            selectRoutine(routine: routine)

        case .registerRecommendedRoutine:
            registerRecommendedRoutine()
        }
    }

    // 선택된 온보딩 결과를 가져옵니다.
    private func fetchChoice(onboarding: OnboardingType) {
        switch onboarding {
        case .time:
            timeOnboardingChoiceSubject.send(timeOnboardingChoiceSubject.value)
            updateNextButtonSubject(choiceSubject: timeOnboardingChoiceSubject)

        case .feeling:
            feelingOnboardingChoiceSubject.send(feelingOnboardingChoiceSubject.value)
            updateNextButtonSubject()

        case .frequency:
            frequencyOnboardingChoiceSubject.send(frequencyOnboardingChoiceSubject.value)
            updateNextButtonSubject(choiceSubject: frequencyOnboardingChoiceSubject)

        case .outdoor:
            outdoorOnboardingChoiceSubject.send(outdoorOnboardingChoiceSubject.value)
            updateNextButtonSubject(choiceSubject: outdoorOnboardingChoiceSubject)
        }
    }

    // 온보딩 선택지를 선택합니다.
    private func selectChoice(choice: OnboardingChoiceType) {
        switch choice.onboardingType {
        case .time, .frequency, .outdoor:
            selectOnlyOneChoice(choice: choice)
        case .feeling:
            selecteMultipleChoices(choice: choice)
        }
    }

    // 온보딩 선택지를 선택합니다. (단일 선택 온보딩)
    private func selectOnlyOneChoice(choice: OnboardingChoiceType) {
        var onboardSubject = CurrentValueSubject<OnboardingChoiceType?, Never>(nil)
        switch choice.onboardingType {
        case .time:
            onboardSubject = timeOnboardingChoiceSubject
        case .frequency:
            onboardSubject = frequencyOnboardingChoiceSubject
        case .outdoor:
            onboardSubject = outdoorOnboardingChoiceSubject
        default:
            onboardSubject = outdoorOnboardingChoiceSubject
        }

        let currentChoice = onboardSubject.value
        onboardSubject.send(nil)
        if choice != currentChoice {
            onboardSubject.send(choice)
        }
        updateNextButtonSubject(choiceSubject: onboardSubject)
    }

    // 온보딩 선택지를 선택합니다. (중복 선택 온보딩)
    private func selecteMultipleChoices(choice: OnboardingChoiceType) {
        var choices = feelingOnboardingChoiceSubject.value
        if choices.contains(choice) {
            choices.remove(choice)
        } else {
            choices.insert(choice)
        }

        feelingOnboardingChoiceSubject.send(choices)
        updateNextButtonSubject()
    }

    // 다음 버튼 활성화 여부를 결정합니다. (단일 선택 온보딩)
    private func updateNextButtonSubject(choiceSubject: CurrentValueSubject<OnboardingChoiceType?, Never>) {
        if choiceSubject.value != nil {
            nextButtonSubject.send(true)
        } else {
            nextButtonSubject.send(false)
        }
    }

    // 다음 버튼 활성화 여부를 결정합니다. (중복 선택 온보딩, 추천 루틴 등록)
    private func updateNextButtonSubject(for registerButton: Bool = false) {
        var result: Bool
        if registerButton {
            result = !selectedRoutineSubject.value.isEmpty
        } else {
            result = !feelingOnboardingChoiceSubject.value.isEmpty
        }
        nextButtonSubject.send(result)
    }

    // 온보딩 결과를 만듭니다.
    private func makeOnboardingResult() {
        let feelingOnboardingChoice = feelingOnboardingChoiceSubject.value
        let feelingResult = feelingOnboardingChoice.compactMap { $0.resultTitle }.joined(separator: ", ")

        guard
            let timeOnboardingChoice = timeOnboardingChoiceSubject.value,
            let outdoorOnboardingChoice = outdoorOnboardingChoiceSubject.value,
            let timeResult = timeOnboardingChoice.resultTitle,
            let outdoorResult = outdoorOnboardingChoice.resultTitle
        else {
            return
        }

        let result = [timeResult, feelingResult, outdoorResult]
        onboardingResultSubject.send(result)
    }

    // 온보딩 결과를 등록하고, 그 결과를 바탕으로 추천 루틴을 받아옵니다.
    private func registerOnboarding() {
        var onboardingChoices: [OnboardingChoiceType] = []

        let feelingOnboarding = Array(feelingOnboardingChoiceSubject.value)
        guard
            let timeOnboarding = timeOnboardingChoiceSubject.value,
            !feelingOnboarding.isEmpty,
            let frequencyOnboarding = frequencyOnboardingChoiceSubject.value,
            let outdoorOnboarding = outdoorOnboardingChoiceSubject.value
        else { return }

        onboardingChoices.append(timeOnboarding)
        onboardingChoices += feelingOnboarding
        onboardingChoices.append(frequencyOnboarding)
        onboardingChoices.append(outdoorOnboarding)

        Task {
            do {
                let entities = try await onboardingUseCase.registerOnboarding(onboardingChoices: onboardingChoices)
                let recommendedRoutines = entities.map({ $0.toRecommendedRoutine() })
                recommendedRoutineSubject.send([])
                recommendedRoutineSubject.send(Set(recommendedRoutines))
            } catch {
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    // 추천 루틴을 선택합니다.
    private func selectRoutine(routine: RecommendedRoutine) {
        var selectedRoutines = selectedRoutineSubject.value
        if selectedRoutines.contains(routine) {
            selectedRoutines.remove(routine)
        } else {
            selectedRoutines.insert(routine)
        }

        selectedRoutineSubject.send(selectedRoutines)
        updateNextButtonSubject(for: true)
    }

    // 추천 루틴을 등록합니다.
    private func registerRecommendedRoutine() {
        let selectedRoutinesId = selectedRoutineSubject.value.map({ $0.id })

        Task {
            do {
                try await onboardingUseCase.registerRecommendedRoutines(selectedRoutines: selectedRoutinesId)
                registerRoutineResultSubject.send(true)
            } catch {
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
                registerRoutineResultSubject.send(false)
            }
        }
    }
}
