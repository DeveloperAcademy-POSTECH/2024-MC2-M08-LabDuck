//
//  KPNodeDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPNodeDTO {
    var id: UUID?
    var title: String?
    var note: String?
    var url: String?
    var tags: [KPTagDTO]?
    var colorTheme: Int?
    var positionX: Double?
    var positionY: Double?
    var sizeWidth: Double?
    var sizeHeight: Double?
    var inputPoints: [KPInputPointDTO]?
    var outputPoints: [KPOutputPointDTO]?
}

extension KPNodeDTO: Codable {}
