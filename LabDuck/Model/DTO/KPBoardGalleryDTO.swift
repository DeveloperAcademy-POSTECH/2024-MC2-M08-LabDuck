//
//  KPBoardGalleryDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/22/24.
//

import Foundation

struct KPBoardGalleryDTO {
    var version: String?
    var boardsURLString: [String]?
}

extension KPBoardGalleryDTO: Codable {}

extension KPBoardGalleryDTO {
    static var emptyData: Self {
        KPBoardGalleryDTO(version: "0.1", boardsURLString: [])
    }
}
