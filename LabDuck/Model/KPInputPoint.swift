//
//  KPInputPoint.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPInputPoint: Identifiable {
    var id: UUID
    var name: String?
    var ownerNode: KPNode.ID?

    init(id: ID = UUID(), name: String? = nil, ownerNode: KPNode.ID? = nil) {
        self.id = id
        self.name = name
        self.ownerNode = ownerNode
    }
}

extension KPInputPoint {
    static var mockData: KPInputPoint {
        KPInputPoint(name: "input1")
    }
}

extension Array where Element == KPInputPoint {
    static var mockData: [KPInputPoint] {
        [
            .init(name: "input1"),
            .init(name: "input2"),
            .init(name: "input3"),
        ]
    }
}
