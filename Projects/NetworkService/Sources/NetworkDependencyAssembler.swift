//
//  NetworkDependencyAssembler.swift
//  NetworkService
//
//  Created by 최정인 on 6/26/25.
//

import DataSource
import Shared

public struct NetworkDependencyAssembler: DependencyAssemblerProtocol {

    public init() { }

    public func assemble() {
        DIContainer.shared.register(type: NetworkServiceProtocol.self) { _ in
            return NetworkService()
        }
    }
}
