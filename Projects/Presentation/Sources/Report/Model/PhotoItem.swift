//
//  PhotoItem.swift
//  Presentation
//
//  Created by 이동현 on 11/9/25.
//

import Foundation

struct PhotoItem: Hashable {
    let id: UUID
    let data: Data

    init(id: UUID = .init(), data: Data) {
        self.id = id
        self.data = data
    }
}
