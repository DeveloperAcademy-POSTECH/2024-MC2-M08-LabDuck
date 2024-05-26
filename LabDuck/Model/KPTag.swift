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

extension Array where Element == KPTag {
    func removingDuplicates() -> [KPTag] {
        var seen = Set<String>()
        return self.filter { tag in
            if seen.contains(tag.name) {
                return false
            } else {
                seen.insert(tag.name)
                return true
            }
        }
    }
}

extension Array<String> {
    // 추후 태그 생성 방식에 대해 더 논의
    func toKPTags() -> [KPTag] {
        self.map { $0.toKPTag() }.removingDuplicates()
    }
}

extension KPTag {
    static let mockData: KPTag = {
        .init(id: UUID(), name: "tag1", colorTheme: KPTagColor.blue)
    }()
    static let mockData1: KPTag = {
        .init(id: UUID(), name: "tag2", colorTheme: KPTagColor.gray)
    }()
    static let mockData2: KPTag = {
        .init(id: UUID(), name: "tag3", colorTheme: KPTagColor.yellow)
    }()
}
