//
//  DependencyInjection.swift
//  App
//
//  Created by 최정인 on 6/26/25.
//

import DataSource
import Domain
import Foundation
import NetworkService
import Persistence
import Presentation
import Shared

extension DIContainer {
    func dependencyInjection() {
        let networkAssembler = NetworkDependencyAssembler()
        let persistenceAssembler = PersistenceDependencyAssembler()
        let dataSourceAssembler = DataSourceDependencyAssembler(preAssemblers: [networkAssembler, persistenceAssembler])
        let domainAssembler = DomainDependencyAssembler(preAssembler: dataSourceAssembler)
        let presentationAssembler = PresentationDependencyAssembler(preAssembler: domainAssembler)
        presentationAssembler.assemble()
    }
}
