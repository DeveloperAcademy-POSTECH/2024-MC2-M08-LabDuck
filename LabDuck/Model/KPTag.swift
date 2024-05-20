//
//  KPTag.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation
import SwiftUI

struct KPTag: Identifiable {
    var id: UUID
    var name: String
    var colorTheme: KPTagColor = KPTagColor.default
}

extension KPTag {
    static var mockData: KPTag {
        .init(id: UUID(), name: "tag1", colorTheme: KPTagColor.blue)
    }
    static var mockData1: KPTag {
        .init(id: UUID(), name: "tag2", colorTheme: KPTagColor.red)
    }
    static var mockData2: KPTag {
        .init(id: UUID(), name: "tag3", colorTheme: KPTagColor.yellow)
    }
}
