//
//  KPTextDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPTextDTO {
    var id: UUID?
    var text: String?
    var positionX: Double?
    var positionY: Double?
    var sizeWidth: Double?
    var sizeHeight: Double?
}

extension KPTextDTO: Codable {}
