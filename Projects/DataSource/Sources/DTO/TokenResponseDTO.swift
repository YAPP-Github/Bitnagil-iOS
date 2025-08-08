//
//  TokenResponseDTO.swift
//  DataSource
//
//  Created by 최정인 on 7/26/25.
//

struct TokenResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
