//
//  KPBoardDTO.swift
//  LabDuck
//
//  Created by 정종인 on 5/23/24.
//

import Foundation

struct KPBoardDTO {
    var id: UUID?
    var title: String?
    var nodes: [KPNodeDTO]?
    var edges: [KPEdgeDTO]?
    var texts: [KPTextDTO]?
    var modifiedDate: Date?
    var viewType: String?
    var previewImage: Data?
}

extension KPBoardDTO: Codable {}
