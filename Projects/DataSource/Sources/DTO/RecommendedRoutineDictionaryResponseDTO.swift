//
//  RecommendedRoutineDictionaryResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/27/25.
//

struct RecommendedRoutineDictionaryResponseDTO: Decodable {
    let recommendedRoutines: [String: [RecommendedRoutineDTO]]
}
