//
//  DomainDependencyAssembler.swift
//  Domain
//
//  Created by 최정인 on 6/26/25.
//

import Shared

public struct DomainDependencyAssembler: DependencyAssemblerProtocol {
    private let preAssembler: DependencyAssemblerProtocol

    public init(preAssembler: DependencyAssemblerProtocol) {
        self.preAssembler = preAssembler
    }

    public func assemble() {
        preAssembler.assemble()

        guard let authRepository = DIContainer.shared.resolve(type: AuthRepositoryProtocol.self)
        else { fatalError("authRepository 의존성이 등록되지 않았습니다.") }

        DIContainer.shared.register(type: LoginUseCaseProtocol.self) { _ in
            return LoginUseCase(authRepository: authRepository)
        }

        DIContainer.shared.register(type: LogoutUseCaseProtocol.self) { _ in
            return LogoutUseCase(authRepository: authRepository)
        }

        DIContainer.shared.register(type: RecommendedRoutineUseCaseProtocol.self) { container in
            guard let recommendedRoutineRepository = container.resolve(type: RecommendedRoutineRepositoryProtocol.self)
            else { fatalError("recommendedRoutineRepository 의존성이 등록되지 않았습니다.") }

            return RecommendedRoutineUseCase(recommendedRoutineRepository: recommendedRoutineRepository)
        }

        guard let emotionRepository = DIContainer.shared.resolve(type: EmotionRepositoryProtocol.self)
        else { fatalError("emotionRepository 의존성이 등록되지 않았습니다.") }

        DIContainer.shared.register(type: EmotionUseCaseProtocol.self) { _ in
            return EmotionUseCase(emotionRepository: emotionRepository)
        }

        DIContainer.shared.register(type: ResultRecommendedRoutineUseCaseProtocol.self) { container in
            guard let onboardingRepository = container.resolve(type: OnboardingRepositoryProtocol.self)
            else { fatalError("onboardingRepository 의존성이 등록되지 않았습니다.") }

            return ResultRecommendedRoutineUseCase(onboardingRepository: onboardingRepository, emotionRepository: emotionRepository)
        }

        DIContainer.shared.register(type: UserDataUseCaseProtocol.self) { container in
            guard let userDataRepository = container.resolve(type: UserDataRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            return UserDataUseCase(userDataRepository: userDataRepository)
        }

        DIContainer.shared.register(type: RoutineUseCaseProtocol.self) { container in
            guard let routineRepository = container.resolve(type: RoutineRepositoryProtocol.self)
            else { fatalError("routineRepository 의존성이 등록되지 않았습니다.") }

            return RoutineUseCase(routineRepository: routineRepository)
        }

        DIContainer.shared.register(type: ReportUseCaseProtocol.self) { container in
            guard
                let locationRepository = container.resolve(type: LocationRepositoryProtocol.self),
                let reportRepository = container.resolve(type: ReportRepositoryProtocol.self)
            else { fatalError("reportUseCase에 필요한 의존성이 등록되지 않았습니다.") }

            return ReportUseCase(locationRepository: locationRepository, reportRepository: reportRepository)
        }
    }
}
