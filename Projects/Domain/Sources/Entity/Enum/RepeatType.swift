//
//  RepeatType.swift
//  Domain
//
//  Created by 이동현 on 8/15/25.
//

public enum RepeatType: Equatable {
    case daily
    case weekly(weeks: Set<Week>)
}
