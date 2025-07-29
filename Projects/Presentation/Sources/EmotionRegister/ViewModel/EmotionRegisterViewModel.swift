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
    }

    struct Output {
        let emotionListPublisher: AnyPublisher<[Emotion], Never>
    }

    private(set) var output: Output
    private let emotionListSubject = CurrentValueSubject<[Emotion], Never>([])

    private let emotionUseCase: EmotionUseCaseProtocol
    init(emotionUseCase: EmotionUseCaseProtocol) {
        self.emotionUseCase = emotionUseCase
        output = Output(
            emotionListPublisher: emotionListSubject.eraseToAnyPublisher()
        )
    }
    
    func action(input: Input) {
        switch input {
        case .fetchEmotions:
            fetchEmotions()
        }
    }

    private func fetchEmotions() {
        Task {
            do {
                let emotionEntities = try await emotionUseCase.fetchEmotions()
                let emotionList = emotionEntities.compactMap({ $0.toEmotion() })
                BitnagilLogger.log(logType: .info, message: "감정 구슬 목록들 조회에 성공했습니다.")
                emotionListSubject.send(emotionList)
            } catch {
                // TODO: 에러 처리 토스트뷰
                BitnagilLogger.log(logType: .error, message: "\(error.localizedDescription)")
            }
        }
    }
}
