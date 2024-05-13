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
    
    var body: some View {
        VStack{
            Table(of: KPNode.self, selection: $selection) {
                TableColumn("색") { node in
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(node.colorTheme.backgroundColor)
                        
                }
                .width(20)
                
                TableColumn("제목") { node in
                    Text(node.title ?? " ")
                }
                
                TableColumn("태그") { node in
                    HStack {
                        ForEach(node.tags) { tag in
                            Text("#\(tag.name)")
                        }
                    }
                }
                
                TableColumn("링크") { node in
                    Link(destination: URL(string: node.url ?? " ")!, label: {
                        Text(node.url ?? " ")
                    })
                }
                
                TableColumn("노트") { node in
                    Text(node.note ?? " ")
                }
                
            } rows: {
                ForEach(nodes) { node in
                    TableRow(node)
                }
            }
        }
        .tableStyle(.inset(alternatesRowBackgrounds: false))
                   .scrollContentBackground(.hidden)
                   .background(RadialGradient(colors:[.white,.white], center:UnitPoint(x:1,y:1), startRadius: 0.0, endRadius:20))
    }
}


#Preview {
    TableView()
}
