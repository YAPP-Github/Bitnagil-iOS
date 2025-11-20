//
//  ReportProgress+.swift
//  Presentation
//
//  Created by 이동현 on 11/20/25.
//

import Domain
import UIKit

extension ReportProgress {
    var backgroundColor: UIColor? {
        switch self {
        case .received:
            BitnagilColor.green10
        case .inProgress:
            BitnagilColor.skyblue10
        case .completed:
            BitnagilColor.gray95
        case .entire:
            nil
        }
    }

    var titleColor: UIColor? {
        switch self {
        case .received:
            BitnagilColor.green500
        case .inProgress:
            BitnagilColor.blue300
        case .completed:
            BitnagilColor.gray40
        case .entire:
            nil
        }
    }
}
