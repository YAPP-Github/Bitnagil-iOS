//
//  DataSourceDependencyAssembler.swift
//  DataSource
//
//  Created by 최정인 on 6/26/25.
//

import Domain
import Foundation
import Shared

public struct DataSourceDependencyAssembler: DependencyAssemblerProtocol {
    public init() { }

    public func assemble() {
        DIContainer.shared.register(type: AuthRepositoryProtocol.self) { _ in
            return AuthRepository()
        }

        DIContainer.shared.register(type: OnboardingRepositoryProtocol.self) { _ in
            return OnboardingRepository()
        }

        DIContainer.shared.register(type: UserDataRepositoryProtocol.self) { _ in
            return UserDataRepository()
        }

        DIContainer.shared.register(type: RecommendedRoutineRepositoryProtocol.self) { _ in
            return RecommendedRoutineRepository()
        }
    }
}
