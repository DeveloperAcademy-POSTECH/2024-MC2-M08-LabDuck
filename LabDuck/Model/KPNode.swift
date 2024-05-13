//
//  KPNode.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPNode: Identifiable {
    var id: UUID
    var title: String?
    var note: String?
    var url: String?
    //    var tags: [KPTag]
    //    var colorTheme: ColorTheme = .default
    var position: CGPoint
    //    var size: CGSize = CGSize(400, 400)
    //    var inputPoints: [KPInputPoint]
    //    var outputPoints: [KPOutputPoint]

    init(id: UUID = UUID(), title: String? = nil, note: String? = nil, url: String? = nil, position: CGPoint = .zero) {
        self.id = id
        self.title = title
        self.note = note
        self.url = url
        self.position = position
    }
}

extension KPNode {
    var unwrappedTitle: String {
        get {
            self.title ?? ""
        }
        set {
            self.title = newValue
        }
    }
    var unwrappedNote: String {
        self.note ?? ""
    }
    var unwrappedURL: String {
        self.url ?? ""
    }
}

extension KPNode {
    static var mockData: Self {
        .init(title: "title1", position: .init(x: 50, y: 20))
    }
}

extension Array where Element == KPNode {
    static var mockData: [Element] = [
        .init(position: .init(x: 50, y: 20)),
        .init(position: .init(x: 80, y: 40)),
        .init(position: .init(x: 110, y: 30)),
        .init(position: .init(x: 140, y: 60)),
        .init(position: .init(x: 170, y: 70)),
    ]
}
