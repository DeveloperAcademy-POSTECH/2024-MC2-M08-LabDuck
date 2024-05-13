//
//  KPInputPoint.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPInputPoint: Identifiable {
    var id: UUID
    var name: String?
    var ownerNode: UUID

    init(name: String? = nil, ownerNode: UUID) {
        self.id = UUID()
        self.name = name
        self.ownerNode = ownerNode
    }
}
