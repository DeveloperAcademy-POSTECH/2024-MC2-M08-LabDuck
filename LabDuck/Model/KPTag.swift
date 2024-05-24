//
//  KPTag.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation
import SwiftUI

struct KPTag: Identifiable, Equatable, Codable, Hashable {
    var id: UUID
    var name: String
    var colorTheme: KPTagColor = KPTagColor.default
}

extension String {
    // 추후 태그 생성 방식에 대해 더 논의
    func toKPTag() -> KPTag {
        KPTag(id: UUID(), name: self)
    }
}

extension Array<String> {
    // 추후 태그 생성 방식에 대해 더 논의
    func toKPTags() -> [KPTag] {
        self.map { $0.toKPTag() }
    }
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
