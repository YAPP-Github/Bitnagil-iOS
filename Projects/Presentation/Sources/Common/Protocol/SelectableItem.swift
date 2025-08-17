//
//  SelectableItem.swift
//  Presentation
//
//  Created by 최정인 on 7/24/25.
//

protocol SelectableItem {
    var id: Int { get }
    var displayName: String? { get }
    var description: String { get }
}
