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
    var allTags: [KPTag]

    enum BoardViewType: String, CaseIterable, Codable, Hashable {
        case graph = "Graph View"
        case table = "Table View"
    }

    init(id: UUID = UUID(), title: String, nodes: [KPNode], edges: [KPEdge], texts: [KPText], modifiedDate: Date, viewType: BoardViewType, previewImage: Data? = nil, allTags: [KPTag] = []) {
        self.id = id
        self.title = title
        self.nodes = nodes
        self.edges = edges
        self.texts = texts
        self.modifiedDate = modifiedDate
        self.viewType = viewType
        self.previewImage = previewImage
        self.allTags = allTags
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
        self.checkIsLinked()
    }

    public mutating func checkIsLinked() {
        self.nodes.enumerated().forEach { index, node in
            node.inputPoints.enumerated().forEach { inputPointIndex, inputPoint in
                if self.edges.contains(where: { $0.sinkID == inputPoint.id }) {
                    self.nodes[index].inputPoints[inputPointIndex].isLinked = true
                } else {
                    self.nodes[index].inputPoints[inputPointIndex].isLinked = false
                }
            }
        }
    }

    public mutating func addNode(_ node: KPNode) {
        self.nodes.append(node)
        
        
    }

    public mutating func addNodes(_ nodes: [KPNode]) {
        self.nodes.append(contentsOf: nodes)
   
    }
    
    public mutating func addDefaultText(_ text: KPText) {
        self.texts.append(text)
    }
    public mutating func deleteDefaultText(_ textID:KPText.ID){
        self.texts.removeAll{ text in
            text.id == textID
        }
    }
    
    public mutating func modified() {
        self.modifiedDate = .now
    }
    
    public func getTag(_ name: String) -> KPTag? {
        let name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return self.allTags.first(where: { $0.name == name })
    }

    public func getTag(_ id: KPTag.ID) -> KPTag? {
        self.allTags.first(where: { $0.id == id })
    }

    public func getTags(_ nodeID: KPNode.ID) -> [KPTag] {
        guard let node = self.nodes.first(where: { $0.id == nodeID }) else { return [] }
        return node.tags
            .compactMap { tagID in
                getTag(tagID)
            }
    }

    public func hasTag(_ nodeID: KPNode.ID, _ tagID: KPTag.ID) -> Bool {
        guard let node = self.nodes.first(where: { $0.id == nodeID }) else { return false }
        return node.tags.contains(where: { $0 == tagID })
    }

    public mutating func createTag(_ name: String) -> KPTag {
        if let tag = getTag(name) {
            return tag
        } else {
            let tag = KPTag(id: UUID(), name: name, colorTheme: .random())
            self.allTags.append(tag)
            return tag
        }
    }

    public mutating func deleteTag(_ tagID: KPTag.ID) {
        self.allTags.removeAll(where: { $0.id == tagID })
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
