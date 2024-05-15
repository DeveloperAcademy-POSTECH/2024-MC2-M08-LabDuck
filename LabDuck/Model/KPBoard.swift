//
//  KPBoard.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import Foundation

struct KPBoard: Identifiable {
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

    public mutating func addEdge(_ edge: KPEdge) {
        self.edges.append(edge)
    }
}

extension KPBoard {
    static var mockData: KPBoard {
        let nodes: [KPNode] = .mockData
        let outputPoint = nodes[0].outputPoints[0]
        let inputPoint = nodes[1].inputPoints[0]
        let edge = KPEdge(sourceID: outputPoint.id, sinkID: inputPoint.id)

        return .init(title: "board1", nodes: .mockData, edges: [edge], texts: [], modifiedDate: .now, viewType: .table)
    }
}
