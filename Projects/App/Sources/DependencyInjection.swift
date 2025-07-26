//
//  DependencyInjection.swift
//  App
//
//  Created by 최정인 on 6/26/25.
//

import DataSource
import Domain
import Foundation
import Presentation
import Shared

extension DIContainer {
    func dependencyInjection() {
        let dataSourceAssembler = DataSourceDependencyAssembler()
        let domainAssembler = DomainDependencyAssembler(preAssembler: dataSourceAssembler)
        let presentationAssembler = PresentationDependencyAssembler(preAssembler: domainAssembler)
        presentationAssembler.assemble()
    }
}
