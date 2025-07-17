//
//  PersistenceDependencyAssembler.swift
//  Persistence
//
//  Created by 최정인 on 6/26/25.
//

import DataSource
import Shared

public struct PersistenceDependencyAssembler: DependencyAssemblerProtocol {

    public init() { }

    public func assemble() {
        DIContainer.shared.register(type: KeychainStorageProtocol.self) { _ in
            return KeychainStorage()
        }

        DIContainer.shared.register(type: UserDefaultsStorageProtocol.self) { _ in
            return UserDefaultsStorage()
        }
    }
}
