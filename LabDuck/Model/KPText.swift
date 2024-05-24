//
//  KPText.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPText: Identifiable, Equatable, Codable, Hashable {
    var id: UUID
    var text: String?
    var position: CGPoint = .zero
    var size: CGSize

    init(id: UUID = UUID(), text: String? = nil, position: CGPoint, size: CGSize = CGSize(width: 200, height: 200)) {
        self.id = id
        self.text = text
        self.position = position
        self.size = size
    }
}

extension KPText {
    static var mockData: KPText {
        .init(text: "조금 있다 읽을 것", position: .init(x: 50, y: 100))
    }
}

extension Array where Element == KPText {
    static var mockData: [KPText] {
        [
            .init(text: "조금 있다 읽을 것", position: .init(x: 50, y: 100)),
            .init(text: "조금 있다 읽을 것2", position: .init(x: 70, y: 110)),
            .init(text: "조금 있다 읽을 것3", position: .init(x: 90, y: 120)),
            .init(text: "조금 있다 읽을 것4", position: .init(x: 110, y: 130)),
            .init(text: "조금 있다 읽을 것5", position: .init(x: 130, y: 140)),
        ]
    }
}
