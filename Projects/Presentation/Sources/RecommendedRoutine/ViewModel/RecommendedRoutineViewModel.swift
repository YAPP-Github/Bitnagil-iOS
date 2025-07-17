//
//  RecommendedRoutineViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/12/25.
//

import Combine

final class RecommendedRoutineViewModel: ViewModel {
    enum Input {
        case selectCategory(selectedCategory: RoutineCategoryType)
        case selectLevel(selectedLevel: RoutineLevelType?)
        case fetchRecommendedRoutines(selectedCategory: RoutineCategoryType)
    }

    struct Output {
        let selectedCategoryPublisher: AnyPublisher<RoutineCategoryType, Never>
        let selectedRoutineLevelPublisher: AnyPublisher<RoutineLevelType?, Never>
        let recommendedRoutinePublisher: AnyPublisher<[RecommendedRoutine], Never>
    }

    private(set) var output: Output
    private let selectedCategorySubject = CurrentValueSubject<RoutineCategoryType, Never>(.recommendation)
    private let selectedRoutineLevelSubject = CurrentValueSubject<RoutineLevelType?, Never>(nil)
    private let recommendedRoutineSubject = CurrentValueSubject<[RecommendedRoutine], Never>([])

    init() {
        self.output = Output(
            selectedCategoryPublisher: selectedCategorySubject.eraseToAnyPublisher(),
            selectedRoutineLevelPublisher: selectedRoutineLevelSubject.eraseToAnyPublisher(),
            recommendedRoutinePublisher: recommendedRoutineSubject.eraseToAnyPublisher()
        )
    }

    func action(input: Input) {
        switch input {
        case .selectCategory(let selectedCategory):
            selectCategory(selectedCategory: selectedCategory)

        case .selectLevel(let selectedLevel):
            selectLevel(selectedLevel: selectedLevel)

        case .fetchRecommendedRoutines(let selectedCategory):
            fetchRecommendedRoutines(selectedCategory: selectedCategory)
        }
    }

    private func selectCategory(selectedCategory: RoutineCategoryType) {
        let currentCategory = selectedCategorySubject.value
        if currentCategory != selectedCategory {
            selectedCategorySubject.send(selectedCategory)
            fetchRecommendedRoutines(selectedCategory: selectedCategory)
        }
    }

    private func selectLevel(selectedLevel: RoutineLevelType?) {
        selectedRoutineLevelSubject.send(selectedLevel)
        // TODO: 현재 보여주고 있는 추천 루틴 난이도 필터링 해야 함
    }

    private func fetchRecommendedRoutines(selectedCategory: RoutineCategoryType) {
        var recommendedRoutines: [RecommendedRoutine] = []
        switch selectedCategory {
        case .recommendation:
            recommendedRoutines = recommendationRoutines
        case .outdoor:
            recommendedRoutines = outdoorRoutines
        case .wakeup:
            recommendedRoutines = wakeupRoutines
        case .connection:
            recommendedRoutines = connectionRoutines
        case .rest:
            recommendedRoutines = restRoutines
        case .growth:
            recommendedRoutines = growthRoutines
        }
        recommendedRoutineSubject.send(recommendedRoutines)
    }


    // TODO: Dummy Data를 지우세요
    private let recommendationRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "쓰레기 버리러 나가기", subTitle: "간단한 외출도 의미있는 변화예요."),
        RecommendedRoutine(id: 2, mainTitle: "산책하며 노란 물건 찾아보기", subTitle: "가까운 공원까지만 나가도 상쾌해져요."),
        RecommendedRoutine(id: 3, mainTitle: "밤 산책하며 노후 가로등 찾기", subTitle: "빛이 희미한 가로등이 있다면 제보해봐요."),
        RecommendedRoutine(id: 4, mainTitle: "산책하며 고장난 표지판 찾기", subTitle: "훼손된 표지판을 제보해봐요.")
    ]

    private let outdoorRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "나가봐요", subTitle: "나가라꼬!!!", routineCategory: .outdoor),
        RecommendedRoutine(id: 2, mainTitle: "나가봐요", subTitle: "나가라꼬!!!", routineCategory: .outdoor),
        RecommendedRoutine(id: 3, mainTitle: "나가봐요", subTitle: "나가라꼬!!!", routineCategory: .outdoor),
        RecommendedRoutine(id: 4, mainTitle: "나가봐요", subTitle: "나가라꼬!!!", routineCategory: .outdoor)
    ]

    private let wakeupRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "일어나요", subTitle: "일어나라꼬!!!", routineCategory: .wakeup),
        RecommendedRoutine(id: 2, mainTitle: "일어나요", subTitle: "일어나라꼬!!!", routineCategory: .wakeup)
    ]

    private let connectionRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "연결해요", subTitle: "연결하라꼬!!!", routineCategory: .connection)
    ]

    private let restRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "쉬어가요", subTitle: "쉬어갑시다아 ~~~ 아아아 ~~", routineCategory: .rest)
    ]

    private let growthRoutines: [RecommendedRoutine] = [
        RecommendedRoutine(id: 1, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 2, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 3, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 4, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 5, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 6, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 7, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 8, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 9, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 10, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 11, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
        RecommendedRoutine(id: 12, mainTitle: "성장해요", subTitle: "성.장.했.다", routineCategory: .growth),
    ]
}
