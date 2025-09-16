//
//  PresentationDependencyAssembler.swift
//  Presentation
//
//  Created by 최정인 on 6/26/25.
//

import Domain
import Shared

public struct PresentationDependencyAssembler: DependencyAssemblerProtocol {
    private let preAssembler: DependencyAssemblerProtocol

    public init(preAssembler: DependencyAssemblerProtocol) {
        self.preAssembler = preAssembler
    }

    public func assemble() {
        preAssembler.assemble()

        DIContainer.shared.register(type: HomeViewModel.self) { container in
            guard let userDataUseCase = container.resolve(type: UserDataUseCaseProtocol.self)
            else { fatalError("userDataUseCase 의존성이 등록되지 않았습니다.") }

            guard let routineUseCase = container.resolve(type: RoutineUseCaseProtocol.self)
            else { fatalError("routineUseCase 의존성이 등록되지 않았습니다.") }

            guard let emotionUseCase = container.resolve(type: EmotionUseCaseProtocol.self)
            else { fatalError("emotionUseCase 의존성이 등록되지 않았습니다.") }

            guard let appConfigRepository = container.resolve(type: AppConfigRepositoryProtocol.self)
            else { fatalError("appConfigRepository 의존성이 등록되지 않았습니다.") }


            return HomeViewModel(
                routineUseCase: routineUseCase,
                userDataUseCase: userDataUseCase,
                emotionUseCase: emotionUseCase,
                appConfigRepository: appConfigRepository)
        }

        DIContainer.shared.register(type: LoginViewModel.self) { container in
            guard let loginUseCase = container.resolve(type: LoginUseCaseProtocol.self)
            else { fatalError("loginUseCase 의존성이 등록되지 않았습니다.") }

            return LoginViewModel(loginUseCase: loginUseCase)
        }

        DIContainer.shared.register(type: OnboardingViewModel.self) { container in
            guard let userDataRepository = container.resolve(type: UserDataRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            guard let onboardingRepository = container.resolve(type: OnboardingRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            return OnboardingViewModel(userDataRepository: userDataRepository, onboardingRepository: onboardingRepository)
        }

        DIContainer.shared.register(type: RecommendedRoutineViewModel.self) { container in
            guard let recommendedRoutineUseCase = container.resolve(type: RecommendedRoutineUseCaseProtocol.self)
            else { fatalError("recommendedRoutineUseCase 의존성이 등록되지 않았습니다.") }

            guard let emotionRepository = container.resolve(type: EmotionRepositoryProtocol.self)
            else { fatalError("emotionRepository 의존성이 등록되지 않았습니다.") }

            return RecommendedRoutineViewModel(recommendedRoutineUseCase: recommendedRoutineUseCase, emotionRepository: emotionRepository)
        }

        DIContainer.shared.register(type: MypageViewModel.self) { container in
            guard let userDataRepository = container.resolve(type: UserDataRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            return MypageViewModel(userDataRepository: userDataRepository)
        }

        DIContainer.shared.register(type: EmotionRegisterViewModel.self) { container in
            guard let emotionUseCase = container.resolve(type: EmotionUseCaseProtocol.self)
            else { fatalError("emotionUseCase 의존성이 등록되지 않았습니다.") }

            return EmotionRegisterViewModel(emotionUseCase: emotionUseCase)
        }

        DIContainer.shared.register(type: RoutineCreationViewModel.self) { container in
            guard
                let routineUseCase = container.resolve(type: RoutineUseCaseProtocol.self),
                let recommendedRoutineUseCase = container.resolve(type: RecommendedRoutineUseCaseProtocol.self)
            else { fatalError("routineUseCase, resultRecommendedRoutineUseCase 의존성이 등록되지 않았습니다.") }

            return RoutineCreationViewModel(routineUseCase: routineUseCase, recommenededRoutineUseCase: recommendedRoutineUseCase)
        }

        DIContainer.shared.register(type: ResultRecommendedRoutineViewModel.self) { container in
            guard let resultRecommendedRoutineUseCase = container.resolve(type: ResultRecommendedRoutineUseCaseProtocol.self)
            else { fatalError("resultRecommendedRoutineUseCase 의존성이 등록되지 않았습니다.") }

            return ResultRecommendedRoutineViewModel(resultRecommendedRoutineUseCase: resultRecommendedRoutineUseCase)
        }

        DIContainer.shared.register(type: SettingViewModel.self) { _ in
            return SettingViewModel()
        }

        DIContainer.shared.register(type: IntroViewModel.self) { container in
            guard let userDataRepository = container.resolve(type: UserDataRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            return IntroViewModel(userDataRepository: userDataRepository)
        }

        DIContainer.shared.register(type: RoutineListViewModel.self) { container in
            guard let routineRepository = container.resolve(type: RoutineRepositoryProtocol.self)
            else { fatalError("routineRepository 의존성이 등록되지 않았습니다.") }

            return RoutineListViewModel(routineRepository: routineRepository)
        }

        DIContainer.shared.register(type: WithdrawViewModel.self) { container in
            guard let authRepository = container.resolve(type: AuthRepositoryProtocol.self)
            else { fatalError("authRepository 의존성이 등록되지 않았습니다.") }

            return WithdrawViewModel(authRepository: authRepository)
        }
    }
}
