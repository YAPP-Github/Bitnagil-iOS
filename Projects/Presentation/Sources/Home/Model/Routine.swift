//
//  Routine.swift
//  Presentation
//
//  Created by 최정인 on 8/6/25.
//

protocol Routine {
    var id: String { get }
    var isDone: Bool { get }
    var routineType: String { get }
    var historySeq: Int { get }
}
