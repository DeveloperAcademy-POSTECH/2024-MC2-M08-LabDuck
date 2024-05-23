//
//  KPOutputPointDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPOutputPointDTO {
    var id: UUID?
    var name: String?
    var ownerNode: UUID?
}

extension KPOutputPointDTO: Codable {}
