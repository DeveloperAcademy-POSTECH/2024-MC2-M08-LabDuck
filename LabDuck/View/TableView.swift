//
//  TableView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/13/24.
//

import SwiftUI

struct TableView: View {
    @Binding var board: KPBoard
    @State private var expanded: Bool = true
    @State private var selection = Set<KPNode.ID>()
    @State private var sortOrder = [KeyPathComparator(\KPNode.title)]
    @State private var searchText = ""
    
    var body: some View {
        VStack{
            Table(of: KPNode.self, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("색", value: \.colorTheme.rawValue)
                { node in
                    Rectangle()
                        .frame(width: 18, height: 18)
                        .cornerRadius(5)
                        .foregroundColor(node.colorTheme.backgroundColor)
                        .padding(4)
                }
                .width(77)
                
                TableColumn("제목", value: \.unwrappedTitle) { node in
                    if let _ = node.title {
                        styledText(node.unwrappedTitle)
                    } else {
                        styledText(node.unwrappedTitle)
                            .foregroundColor(.secondary)
                    }
                }
                
                TableColumn("노트", value: \.unwrappedNote) { node in
                    styledText(node.unwrappedNote)
                }
                
                TableColumn("태그") { node in
                    ScrollView(.horizontal) {
                        HStack() {
                            ForEach(node.tags) { tag in
                                Button(action: {
                                    // 추후 tag를 눌렀을 때 기능 추가 가능하도록
                                }) {
                                    Text("#\(tag.name)")
                                        .font(.system(size: 13.0))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                        .padding(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                                        .background(tag.colorTheme.backgroundColor)
                                        .cornerRadius(6)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .padding([.leading, .trailing], 10)
                    }
                    .scrollIndicators(.hidden)
                }
                
                TableColumn("링크", value: \.unwrappedURL) { node in
                    Link(destination: URL(string: node.url ?? " ")!, label: {
                        styledText(node.unwrappedURL)
                            .underline()
                    })
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
                board.nodes.sort(using: newSortOrder)}
            .onChange(of: selection) { _, newSelection in
                updateSelection(newSelection: newSelection)}
            .searchable(text: $searchText)
        }
    }
    
    // MARK: - 노드의 ouputPoint에 대한 inputPoint들을 찾아 해당 노드들 리턴
    func findNodes(matching node: KPNode) -> [KPNode] {
        let sourceIDs = node.outputPoints.map { $0.id }
        
        let matchingSinkIDs = board.edges.filter { sourceIDs.contains($0.sourceID) }.map { $0.sinkID }

        var nodeDict = [UUID: KPNode]()
        
        board.nodes.forEach { node in
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
            if let node = board.nodes.first(where: { $0.id == nodeID }) {
                allSelectedIDs.insert(node.id)
            }
        }
        
        selection = allSelectedIDs
    }
    
    // MARK: - 필터링 기능
    var filteredNodes: [KPNode] {
        if searchText.isEmpty {
            return board.nodes
        } else {
            return board.nodes.filter { node in
                let titleMatch = node.unwrappedTitle.lowercased().contains(searchText.lowercased())
                let tagsMatch = node.tags.map { $0.name.lowercased() }.contains { $0.contains(searchText.lowercased()) }
                let urlMatch = node.unwrappedURL.lowercased().contains(searchText.lowercased())
                let noteMatch = node.unwrappedNote.lowercased().contains(searchText.lowercased())
                
                return titleMatch || tagsMatch || urlMatch || noteMatch
            }
        }
    }
    
    func styledText(_ text: String) -> some View {
        return Text(text)
            .font(.system(size: 13.0))
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .lineLimit(1)
    }

}

#Preview {
    TableView(board: .constant(.mockData))
}
