//
//  KPOutputPoint.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPOutputPoint: Identifiable {
    var id: UUID
    var name: String?
    var ownerNode: KPNode.ID?

    init(name: String? = nil, ownerNode: KPNode.ID? = nil) {
        self.id = UUID()
        self.name = name
        self.ownerNode = ownerNode
    }
}

extension KPOutputPoint {
    static var mockData: KPOutputPoint {
        KPOutputPoint(name: "output1")
    }
}

extension Array where Element == KPOutputPoint {
    static var mockData: [KPOutputPoint] {
        [
            .init(name: "output1"),
            .init(name: "output2"),
            .init(name: "output3"),
        ]
    }
}
