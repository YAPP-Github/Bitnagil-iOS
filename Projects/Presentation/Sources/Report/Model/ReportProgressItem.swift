//
//  ReportProgressItem.swift
//  Presentation
//
//  Created by 이동현 on 11/17/25.
//

import Domain
import Foundation

struct ReportProgressItem: Hashable {
    let uuid: UUID
    let progress: ReportProgress
    let count: Int
    var isSelected: Bool
}
