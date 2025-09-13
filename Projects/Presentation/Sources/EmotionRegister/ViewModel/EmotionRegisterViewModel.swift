//
//  EmotionRegisterViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import Combine
import Domain
import Shared

final class EmotionRegisterViewModel: ViewModel {
    enum Input {
        case fetchEmotions
        case selectEmotion(index: Int)
    }

    struct Output {
        let emotionListPublisher: AnyPublisher<[Emotion], Never>
        let selectedEmotionPublisher: AnyPublisher<Emotion?, Never>
        let confirmEmotionEnabledPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let emotionListSubject = CurrentValueSubject<[Emotion], Never>([])
    private let selectedEmotionSubject = CurrentValueSubject<Emotion?, Never>(nil)
    private let confirmEmotionEnabledSubject = PassthroughSubject<Bool, Never>()

    private let emotionUseCase: EmotionUseCaseProtocol
    init(emotionUseCase: EmotionUseCaseProtocol) {
        self.emotionUseCase = emotionUseCase
        output = Output(
            emotionListPublisher: emotionListSubject.eraseToAnyPublisher(),
            selectedEmotionPublisher: selectedEmotionSubject.eraseToAnyPublisher(),
            confirmEmotionEnabledPublisher: confirmEmotionEnabledSubject.eraseToAnyPublisher())
    }
    
    func action(input: Input) {
        switch input {
        case .fetchEmotions:
            fetchEmotions()
        case .selectEmotion(let index):
            selectEmotion(index: index)
        }
    }

    private func fetchEmotions() {
        Task {
            do {
                let emotionEntities = try await emotionUseCase.fetchEmotions()
//                let emotionList = emotionEntities.compactMap({ $0.toEmotion() })
                // TODO: - 서버 연동 후 삭제
                let emotionList = emotinonDummies
                BitnagilLogger.log(logType: .info, message: "감정 구슬 목록들 조회에 성공했습니다.")
                emotionListSubject.send(emotionList)
            } catch {
                // TODO: 에러 처리 토스트뷰
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }

    private func selectEmotion(index: Int) {
        let emotions = emotionListSubject.value

        guard
            index >= 0,
            index < emotions.count
        else { return }

        let emotion = emotions[index]

        selectedEmotionSubject.send(emotion)
        confirmEmotionEnabledSubject.send(emotion.emotionType != "NONE")
    }
}
