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

    enum BoardViewType: String, CaseIterable, Codable, Hashable {
        case graph = "Graph View"
        case table = "Table View"
    }

    init(id: UUID = UUID(), title: String, nodes: [KPNode], edges: [KPEdge], texts: [KPText], modifiedDate: Date, viewType: BoardViewType, previewImage: Data? = nil) {
        self.id = id
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
        
        self.nodes.enumerated().forEach { nodeIndex, node in
            node.inputPoints.enumerated().forEach { inputPointIndex, inputPoint in
                if inputPoint.id == edge.sinkID {
                    self.nodes[nodeIndex].inputPoints[inputPointIndex].isLinked = true
                }
            }
        }
    }

    public mutating func removeEdge(_ edgeID: KPEdge.ID) {
        self.edges.removeAll { edge in
            edge.id == edgeID
        }
    }

    public mutating func addNode(_ node: KPNode) {
        self.nodes.append(node)
    }

    public mutating func addNodes(_ nodes: [KPNode]) {
        self.nodes.append(contentsOf: nodes)
    }

    public mutating func modified() {
        self.modifiedDate = .now
    }
}

extension KPBoard: Equatable, Codable, Hashable {}

extension KPBoard {
    static var mockData: KPBoard {
        let nodes: [KPNode] = .mockData
        let outputPoint = nodes[0].outputPoints[0]
        let inputPoint = nodes[1].inputPoints[0]
        let edge = KPEdge(sourceID: outputPoint.id, sinkID: inputPoint.id)

        return .init(title: "board1", nodes: .mockData, edges: [edge], texts: [], modifiedDate: .now, viewType: .table)
    }
    
    static var mockData2: KPBoard {
        let nodes: [KPNode] = .mockData
        let outputPoint = nodes[0].outputPoints[0]
        let inputPoint = nodes[1].inputPoints[0]
        let edge = KPEdge(sourceID: outputPoint.id, sinkID: inputPoint.id)

        return .init(title: "내가만든보드", nodes: .mockData, edges: [edge], texts: [], modifiedDate: .now, viewType: .table)
    }

    static var emptyData: KPBoard {
        KPBoard(title: "Untitled", nodes: [], edges: [], texts: [], modifiedDate: .now, viewType: .table)
    }
}
