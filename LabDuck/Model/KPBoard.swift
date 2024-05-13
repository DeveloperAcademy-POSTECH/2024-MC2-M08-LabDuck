//
//  KPBoard.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

@Observable
class KPBoard: Identifiable {
    var id: UUID
    var title: String
    var nodes: [KPNode]
    var edges: [KPEdge]
    var texts: [KPText]
    var modifiedDate: Date
    var viewType: BoardViewType
    var previewImage: Data?

    enum BoardViewType {
        case graph
        case table
    }
    
    init(title: String, nodes: [KPNode], edges: [KPEdge], texts: [KPText], modifiedDate: Date, viewType: BoardViewType, previewImage: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.nodes = nodes
        self.edges = edges
        self.texts = texts
        self.modifiedDate = modifiedDate
        self.viewType = viewType
        self.previewImage = previewImage
    }
}
