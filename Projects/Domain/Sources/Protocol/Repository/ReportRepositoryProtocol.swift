//
//  ReportRepositoryProtocol.swift
//  Domain
//
//  Created by 이동현 on 11/9/25.
//

public protocol ReportRepositoryProtocol {
    func report(reportEntity: ReportEntity) async
}
