//
//  KPTag.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPTag: Identifiable {
    var id: UUID
    var name: String
}

extension KPTag {
    static var mockData: KPTag {
        .init(id: UUID(), name: "tag1")
    }
}
