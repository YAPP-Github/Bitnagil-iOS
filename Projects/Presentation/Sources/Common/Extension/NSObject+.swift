//
//  NSObject+.swift
//  Presentation
//
//  Created by 이동현 on 7/20/25.
//

import Foundation

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }

    class var className: String {
        return String(describing: self)
    }
}
