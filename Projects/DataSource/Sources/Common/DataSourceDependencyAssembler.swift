//
//  DataSourceDependencyAssembler.swift
//  DataSource
//
//  Created by 최정인 on 6/26/25.
//

import Foundation
import Domain
import Shared

public struct DataSourceDependencyAssembler: DependencyAssemblerProtocol {
    private let preAssemblers: [DependencyAssemblerProtocol]

    public init(preAssemblers: [DependencyAssemblerProtocol]) {
        self.preAssemblers = preAssemblers
    }

    public func assemble() {
        preAssemblers.forEach { assembler in
            assembler.assemble()
        }
        
        guard
            let networkService = DIContainer.shared.resolve(type: NetworkServiceProtocol.self),
            let keychainStorage = DIContainer.shared.resolve(type: KeychainStorageProtocol.self),
            let userDefaultsStorage = DIContainer.shared.resolve(type: UserDefaultsStorageProtocol.self)
        else { fatalError("networkService, keychainStorage, userDefaultsStorage 의존성이 등록되지 않았습니다.") }

        DIContainer.shared.register(type: AuthRepositoryProtocol.self) { _ in
            return AuthRepository(
                networkService: networkService,
                keychainStorage: keychainStorage,
                userDefaultsStorage: userDefaultsStorage)
        }

        DIContainer.shared.register(type: OnboardingRepositoryProtocol.self) { _ in
            return OnboardingRepository(networkService: networkService, keychainStorage: keychainStorage)
        }
    }
}
