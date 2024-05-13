//
//  KPNode.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPNode: Identifiable {
    var id: UUID
    var title: String?
    var note: String?
    var url: String?
    var tags: [KPTag] = []
    var colorTheme: KPColorTheme = .default
    var position: CGPoint = .zero
    var size: CGSize
    var inputPoints: [KPInputPoint] = []
    var outputPoints: [KPOutputPoint] = []

    init(title: String? = nil, note: String? = nil, url: String? = nil, tags: [KPTag] = [], colorTheme: KPColorTheme = .default, position: CGPoint = .zero, size: CGSize = CGSize(width: 400, height: 400), inputPoints: [KPInputPoint] = [], outputPoints: [KPOutputPoint] = []) {
        self.id = UUID()
        self.title = title
        self.note = note
        self.url = url
        self.tags = tags
        self.colorTheme = colorTheme
        self.position = position
        self.size = size
        self.inputPoints = inputPoints
        self.outputPoints = outputPoints
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
        get {
            self.note ?? ""
        }
        set {
            self.note = newValue
        }
    }
    var unwrappedURL: String {
        get {
            self.url ?? ""
        }
        set {
            self.url = newValue
        }
    }
}

extension KPNode {
    static var mockData: KPNode {
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
