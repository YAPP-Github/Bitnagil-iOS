//
//  EmotionRegisterViewModel.swift
//  Presentation
//
//  Created by 최정인 on 7/28/25.
//

import Combine

final class EmotionRegisterViewModel: ViewModel {
    enum Input {
        case selectEmotion(emotion: EmotionType)
    }

    struct Output {
        let registerEmotionResultPublisher: AnyPublisher<Bool, Never>
    }

    private(set) var output: Output
    private let registerEmotionResultSubject = PassthroughSubject<Bool, Never>()
    init() {
        output = Output(
            registerEmotionResultPublisher: registerEmotionResultSubject.eraseToAnyPublisher()
        )
    }
    
    func action(input: Input) {
        switch input {
        case .selectEmotion(let emotion):
            registerEmotion(emotion: emotion)
        }
    }

    private func registerEmotion(emotion: EmotionType) {
        // TODO: 서버 통신 로직
        registerEmotionResultSubject.send(true)
    }
}
