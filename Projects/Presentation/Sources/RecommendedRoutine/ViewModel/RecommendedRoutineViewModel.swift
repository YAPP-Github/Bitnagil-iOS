//
//  RecommendedRoutineViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Combine
import Domain
import Foundation
import Shared

final class RecommendedRoutineViewModel: ViewModel {
    enum Input {
        case fetchRecommendedRoutines
        case loadEmotion
        case selectCategory(selectedCategory: RoutineCategoryType)
        case selectLevel(selectedLevel: RoutineLevelType?)
    }

    struct Output {
        let selectedCategoryPublisher: AnyPublisher<RoutineCategoryType, Never>
        let selectedRoutineLevelPublisher: AnyPublisher<RoutineLevelType?, Never>
        let recommendedRoutinePublisher: AnyPublisher<[RecommendedRoutine], Never>
        let emotionExistPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private var recommendedRoutines: [RecommendedRoutine] = []
    private let selectedCategorySubject = CurrentValueSubject<RoutineCategoryType, Never>(.recommendation)
    private let selectedRoutineLevelSubject = CurrentValueSubject<RoutineLevelType?, Never>(nil)
    private let recommendedRoutineSubject = CurrentValueSubject<[RecommendedRoutine], Never>([])
    private let emotionExistSubject = CurrentValueSubject<Bool, Never>(false)

    private let recommendedRoutineUseCase: RecommendedRoutineUseCaseProtocol
    private let emotionRepository: EmotionRepositoryProtocol
    init(recommendedRoutineUseCase: RecommendedRoutineUseCaseProtocol, emotionRepository: EmotionRepositoryProtocol) {
        self.recommendedRoutineUseCase = recommendedRoutineUseCase
        self.emotionRepository = emotionRepository
        self.output = Output(
            selectedCategoryPublisher: selectedCategorySubject.eraseToAnyPublisher(),
            selectedRoutineLevelPublisher: selectedRoutineLevelSubject.eraseToAnyPublisher(),
            recommendedRoutinePublisher: recommendedRoutineSubject.eraseToAnyPublisher(),
            emotionExistPublisher: emotionExistSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .fetchRecommendedRoutines:
            fetchRecommendedRoutines()

        case .loadEmotion:
            loadEmotion()
            
        case .selectCategory(let selectedCategory):
            selectCategory(selectedCategory: selectedCategory)

        case .selectLevel(let selectedLevel):
            selectLevel(selectedLevel: selectedLevel)
        }
    }

    // 전체 추천 루틴을 조회합니다.
    private func fetchRecommendedRoutines() {
        Task {
            do {
                let recommendedRoutineEntities = try await recommendedRoutineUseCase.fetchRecommendedRoutines()
                let fetchedRecommendedRoutines = recommendedRoutineEntities.compactMap({ $0.toRecommendedRoutine() })
                recommendedRoutines = fetchedRecommendedRoutines

                let currentCategory = selectedCategorySubject.value
                filterRecommendedRoutines(category: currentCategory, level: nil)
            } catch {
                // TODO: 에러 토스트 메시지 보여주기
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    // 루틴 카테고리를 선택합니다.
    private func selectCategory(selectedCategory: RoutineCategoryType) {
        let currentCategory = selectedCategorySubject.value
        if currentCategory != selectedCategory {
            selectedCategorySubject.send(selectedCategory)

            let currentLevel = selectedRoutineLevelSubject.value
            filterRecommendedRoutines(category: selectedCategory, level: currentLevel)
        }
    }

    // 루틴 난이도를 선택합니다.
    private func selectLevel(selectedLevel: RoutineLevelType?) {
        selectedRoutineLevelSubject.send(selectedLevel)

        let currentCategory = selectedCategorySubject.value
        filterRecommendedRoutines(category: currentCategory, level: selectedLevel)
    }

    // 추천 루틴을 필터링합니다.
    private func filterRecommendedRoutines(category: RoutineCategoryType, level: RoutineLevelType?) {
        let filteredByCategory = recommendedRoutines.filter({ $0.routineCategory == category })
        if let level {
            let filteredByLevel = filteredByCategory.filter({ $0.routineLevel == level })
            recommendedRoutineSubject.send(filteredByLevel)
        } else {
            recommendedRoutineSubject.send(filteredByCategory)
        }
    }

    // 감정 구슬을 불러옵니다.
    private func loadEmotion() {
        Task {
            do {
                let emotionEntity = try await emotionRepository.fetchEmotion(date: Date().convertToString(dateType: .yearMonthDate))
                if emotionEntity == nil {
                    emotionExistSubject.send(false)
                } else {
                    emotionExistSubject.send(true)
                }
            } catch {

            }
        }
    }
}
