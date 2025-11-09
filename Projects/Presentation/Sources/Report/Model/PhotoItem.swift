//
//  PhotoItem.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

public struct PhotoItem: Hashable {
    public let id: UUID
    public let data: Data

    public init(id: UUID = .init(), data: Data) {
        self.id = id
        self.data = data
    }
}
