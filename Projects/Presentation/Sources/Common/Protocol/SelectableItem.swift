//
//  SelectableItem.swift
//  Presentation
//
//  Created by 최정인 on 7/24/25.
//

import UIKit

protocol SelectableItem {
    var id: Int { get }
    var displayName: String? { get }
    var description: String { get }
    var icon: UIImage? { get }
}

extension SelectableItem {
    var icon: UIImage? { return nil }
}
