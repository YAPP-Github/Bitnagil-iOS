//
//  FilePresignedDTO.swift
//  DataSource
//
//  Created by 이동현 on 11/22/25.
//

struct FilePresignedDTO: Decodable {
    let file1: String?
    let file2: String?
    let file3: String?

    enum CodingKeys: String, CodingKey {
        case file1 = "additionalProp1"
        case file2 = "additionalProp2"
        case file3 = "additionalProp3"
    }
}
