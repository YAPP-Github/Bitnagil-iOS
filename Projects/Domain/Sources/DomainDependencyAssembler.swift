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

        guard let analyticsLogger = DIContainer.shared.resolve(type: AnalyticsLoggerProtocol.self)
        else { fatalError("analyticsLogger 의존성이 등록되지 않았습니다.") }

        DIContainer.shared.register(type: LoginUseCaseProtocol.self) { _ in
            return LoginUseCase(authRepository: authRepository, analyticsLogger: analyticsLogger)
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

            return ResultRecommendedRoutineUseCase(
                onboardingRepository: onboardingRepository,
                emotionRepository: emotionRepository,
                analyticsLogger: analyticsLogger)
        }

        DIContainer.shared.register(type: UserDataUseCaseProtocol.self) { container in
            guard let userDataRepository = container.resolve(type: UserDataRepositoryProtocol.self)
            else { fatalError("userDataRepository 의존성이 등록되지 않았습니다.") }

            return UserDataUseCase(userDataRepository: userDataRepository)
        }

        DIContainer.shared.register(type: RoutineUseCaseProtocol.self) { container in
            guard let routineRepository = container.resolve(type: RoutineRepositoryProtocol.self)
            else { fatalError("routineRepository 의존성이 등록되지 않았습니다.") }

            return RoutineUseCase(routineRepository: routineRepository, analyticsLogger: analyticsLogger)
        }

        DIContainer.shared.register(type: ReportUseCaseProtocol.self) { container in
            guard
                let locationRepository = container.resolve(type: LocationRepositoryProtocol.self),
                let reportRepository = container.resolve(type: ReportRepositoryProtocol.self),
                let fileRepository = container.resolve(type: FileRepositoryProtocol.self)
            else { fatalError("reportUseCase에 필요한 의존성이 등록되지 않았습니다.") }

            return ReportUseCase(
                locationRepository: locationRepository,
                reportRepository: reportRepository,
                fileRepository: fileRepository)
        }

        DIContainer.shared.register(type: YouthPolicyUseCaseProtocol.self) { container in
            guard
                let youthPolicyRepository = container.resolve(type: YouthPolicyRepositoryProtocol.self),
                let locationRepository = container.resolve(type: LocationRepositoryProtocol.self)
            else { fatalError("youthPolicyUseCase에 필요한 의존성이 등록되지 않았습니다.") }

            return YouthPolicyUseCase(
                youthPolicyRepository: youthPolicyRepository,
                locationRepository: locationRepository)
        }
    }
}
