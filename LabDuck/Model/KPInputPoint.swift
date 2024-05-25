//
//  KPInputPoint.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPInputPoint: Identifiable, Equatable, Codable, Hashable {
    var id: UUID
    var name: String?
    var ownerNode: KPNode.ID?
    var isLinked: Bool

    init(id: ID = UUID(), name: String? = nil, ownerNode: KPNode.ID? = nil, isLinked: Bool = false) {
        self.id = id
        self.name = name
        self.ownerNode = ownerNode
        self.isLinked = isLinked
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
