//
//  TableView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/13/24.
//

import SwiftUI

struct TableView: View {
    @State var nodes: [KPNode] = .mockData
    @State private var expanded: Bool = true
    @State private var selection = Set<KPNode.ID>()
    @State private var sortOrder = [KeyPathComparator(\KPNode.title)]
    @State private var searchText = ""
    //Edge 더미데이터 -> 표에서 output을 표현하기 위함
    @State var edges: [KPEdge] = [
        KPEdge(sourceID: Array.mockData[0].outputPoints[0].id, sinkID: Array.mockData[1].inputPoints[0].id),
        KPEdge(sourceID: Array.mockData[0].outputPoints[0].id, sinkID: Array.mockData[3].inputPoints[0].id),
        KPEdge(sourceID: Array.mockData[0].outputPoints[0].id, sinkID: Array.mockData[4].inputPoints[0].id),
        KPEdge(sourceID: Array.mockData[0].outputPoints[0].id, sinkID: Array.mockData[3].inputPoints[1].id),
    ]
    
    var body: some View {
        VStack{
            Table(of: KPNode.self, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("색", value: \.colorTheme.rawValue) { node in
                    Circle()
                        .foregroundColor(node.colorTheme.backgroundColor)
                }
                .width(30)
                
                TableColumn("제목", value: \.unwrappedTitle) { node in
                    Text(node.unwrappedTitle)
                        .lineLimit(1)
                        .padding(10)
                }
                
                TableColumn("태그") { node in
                    HStack {
                        ForEach(node.tags) { tag in
                            Button(action: {
                                // 추후 tag를 눌렀을 때 기능 추가 가능하도록
                            }) {
                                Text("#\(tag.name)")
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(tag.colorTheme)
                                    .cornerRadius(40)
                            }
                        }
                    }
                }
                
                TableColumn("링크", value: \.unwrappedURL) { node in
                    Link(destination: URL(string: node.url ?? " ")!, label: {
                        Text(node.unwrappedURL)
                            .lineLimit(1)
                    })
                }
                
                TableColumn("노트", value: \.unwrappedNote) { node in
                    Text(node.unwrappedNote)
                }
                
            } rows: {
                ForEach(filteredNodes, id: \.id) { node in
                    if findNodes(matching: node).isEmpty {
                        TableRow(node)
                    } else {
                        DisclosureTableRow(node) {
                            ForEach(findNodes(matching: node).sorted(using: sortOrder)) { subNode in
                                TableRow(subNode)
                            }
                        }
                    }
                }
            }
            .tableStyle(.inset(alternatesRowBackgrounds: false))
            .scrollContentBackground(.hidden)
            .onChange(of: sortOrder) { _, newSortOrder in
                nodes.sort(using: newSortOrder)}
            .onChange(of: selection) { _, newSelection in
                updateSelection(newSelection: newSelection)}
            .searchable(text: $searchText)
        }
    }
    // MARK: - 노드의 ouputPoint에 대한 inputPoint들을 찾아 해당 노드들 리턴
    func findNodes(matching node: KPNode) -> [KPNode] {
        let sourceIDs = node.outputPoints.map { $0.id }
        
        let matchingSinkIDs = edges.filter { sourceIDs.contains($0.sourceID) }.map { $0.sinkID }
        
        var nodeDict = [UUID: KPNode]()
        
        nodes.forEach { node in
            node.inputPoints.forEach { inputPoint in
                if matchingSinkIDs.contains(inputPoint.id) {
                    nodeDict[node.id] = node
                }
            }
        }
        
        return Array(nodeDict.values)
    }
    // MARK: - selection된 리스트를 받아서 같은 id인 것들을 업데이트
    func updateSelection(newSelection: Set<KPNode.ID>) {
        var allSelectedIDs = newSelection
        
        newSelection.forEach { nodeID in
            if let node = nodes.first(where: { $0.id == nodeID }) {
                allSelectedIDs.insert(node.id)
            }
        }
        
        selection = allSelectedIDs
    }
    // MARK: - 필터링 기능
    var filteredNodes: [KPNode] {
        if searchText.isEmpty {
            return nodes
        } else {
            return nodes.filter { node in
                let titleMatch = node.unwrappedTitle.lowercased().contains(searchText.lowercased())
                let tagsMatch = node.tags.map { $0.name.lowercased() }.contains { $0.contains(searchText.lowercased()) }
                let urlMatch = node.unwrappedURL.lowercased().contains(searchText.lowercased())
                let noteMatch = node.unwrappedNote.lowercased().contains(searchText.lowercased())
                return titleMatch || tagsMatch || urlMatch || noteMatch
            }
        }
    }

}

#Preview {
    TableView()
}
