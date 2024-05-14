//
//  TableView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/13/24.
//

import SwiftUI

struct TableView: View {
    @State private var nodes: [KPNode] = .mockData
    @State private var selection = Set<KPNode.ID>()
    @State private var sortOrder = [KeyPathComparator(\KPNode.title)]
    
    var body: some View {
        VStack{
            Table(nodes, selection: $selection, sortOrder: $sortOrder) {
                TableColumn("색", value: \.colorTheme.rawValue) { node in
                    Circle()
                        .foregroundColor(node.colorTheme.backgroundColor)
                }
                .width(20)
                
                TableColumn("제목", value: \.unwrappedTitle) { node in
                    Text(node.unwrappedTitle)
                        .lineLimit(1)
                        .padding(10)
                }
                
                TableColumn("태그") { node in
                    HStack {
                        ForEach(node.tags) { tag in
                            Text("#\(tag.name)")
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
                
            }
            .tableStyle(.inset(alternatesRowBackgrounds: false))
            .scrollContentBackground(.hidden)
            .onChange(of: sortOrder) { newOrder in
                nodes.sort(using: newOrder)
            }
        
            
        }
    }
}



#Preview {
    TableView()
}
