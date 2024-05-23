//
//  KPTagDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPTagDTO {
    var id: UUID?
    var name: String?
    var colorTheme: String?
}

extension KPTagDTO: Codable {}
