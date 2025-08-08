//
//  TermsAgreementState.swift
//  Presentation
//
//  Created by 최정인 on 7/8/25.
//

import Domain

struct TermsAgreementState {
    private(set) var agreements: [TermsType: Bool] = [
        .service: false,
        .privacy: false,
        .age: false
    ]

    var isAllAgreed: Bool {
        return agreements.filter({ $0.value == false }).isEmpty
    }

    func isAgreed(termType: TermsType) -> Bool {
        guard let agreement = agreements[termType] else { return false }
        return agreement
    }

    mutating func toggleState(termType: TermsType) {
        agreements[termType]?.toggle()
    }

    mutating func togleAllStates() {
        let state = !isAllAgreed
        TermsType.allCases.forEach { type in
            agreements[type] = state
        }
    }
}
