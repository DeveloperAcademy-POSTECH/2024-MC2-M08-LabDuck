//
//  KPEdgeDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPEdgeDTO {
    var id: UUID?
    var sourceID: UUID?
    var sinkID: UUID?
}

extension KPEdgeDTO: Codable {}
