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
        // Meta SDK 의존성은 App 타겟에만 두고, Domain에는 프로토콜로 주입합니다.
        DIContainer.shared.register(type: AnalyticsLoggerProtocol.self) { _ in
            return MetaAnalyticsLogger()
        }

        let dataSourceAssembler = DataSourceDependencyAssembler()
        let domainAssembler = DomainDependencyAssembler(preAssembler: dataSourceAssembler)
        let presentationAssembler = PresentationDependencyAssembler(preAssembler: domainAssembler)
        presentationAssembler.assemble()
    }
}
