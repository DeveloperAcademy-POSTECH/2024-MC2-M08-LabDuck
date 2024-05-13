//
//  NodeView.swift
//  LabDuck
//
//  Created by 정종인 on 5/13/24.
//

import SwiftUI

struct NodeView: View {
    @Binding var node: KPNode
    var body: some View {
        VStack {
            Text("asdf")
            Text(node.unwrappedTitle)
            TextField("title", text: $node.unwrappedTitle)
        }
        .padding()
        .background(Color.pink)
        .border(Color.black, width: 2.0)
        .frame(maxWidth: 250, maxHeight: 50)
        .draggable(offset: $node.position)
    }
}

#Preview {
    NodeView(node: .constant(.mockData))
}
