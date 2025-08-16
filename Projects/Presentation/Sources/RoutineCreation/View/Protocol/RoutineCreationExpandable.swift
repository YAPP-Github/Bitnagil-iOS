//
//  RoutineCreationExpandable.swift
//  Presentation
//
//  Created by 이동현 on 8/10/25.
//

import SnapKit
import UIKit

protocol RoutineCreationExpandable: UIView {
    associatedtype Action
    associatedtype Dependency

    /// RoutineCreationExpandableContentView 에서 일어날 수 있는 action을 전달합니다.
    var action: ((Action) -> Void)? { get set }
    var heightConstraint: Constraint? { get set }

    func setExpanded(expanded: Bool)
    func configure(dependency: Dependency)
}

