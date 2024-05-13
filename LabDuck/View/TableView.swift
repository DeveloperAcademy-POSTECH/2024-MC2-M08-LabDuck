//
//  TableView.swift
//  LabDuck
//
//  Created by hanseoyoung on 5/13/24.
//

import SwiftUI

struct TableView: View {
    @State private var nodes: [KPNode] = .mockData
    var body: some View {
        VStack{
            Table(of: KPNode.self) {
                TableColumn("제목") { node in
                    
                    Text(node.title ?? " ")
                }
                
            } rows: {
                ForEach(nodes) { node in
                    TableRow(node)
                }
            }
        }
    }
}


#Preview {
    TableView()
}
