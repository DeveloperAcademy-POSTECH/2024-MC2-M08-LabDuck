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
    var ownerNode: KPNode.ID

    init(name: String? = nil, ownerNode: KPNode.ID) {
        self.id = UUID()
        self.name = name
        self.ownerNode = ownerNode
    }
}
