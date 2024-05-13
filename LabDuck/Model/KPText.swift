//
//  KPText.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPText: Identifiable {
    var id: UUID
    var text: String?
    var position: CGPoint = .zero
    var size: CGSize = CGSize(width: 200, height: 200)

    init(text: String? = nil, position: CGPoint, size: CGSize) {
        self.id = UUID()
        self.text = text
        self.position = position
        self.size = size
    }
}
